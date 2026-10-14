"""Run with: python -m unittest discover -s tests -v (requires Helm, jq, PyYAML).

Execute the rendered Bash script with fake kubectl/curl/cat commands. No
cluster, registry, or credentials are accessed.
"""

import copy
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

import yaml

ROOT = Path(__file__).resolve().parents[1]
A = "sha256:" + "a" * 64
B = "sha256:" + "b" * 64


def render(*extra):
    output = subprocess.check_output(
        ["helm", "template", "maestrod", str(ROOT / "charts/maestrod"),
         "--set", "restartJob.enabled=true",
         "--set", "restartJob.registryAuthSecretName=test-registry",
         "--set", "image.repository=registry.example/maestrod",
         "--set", "image.tag=nightly", *extra], text=True,
    )
    return {doc["kind"]: doc for doc in yaml.safe_load_all(output) if doc}


def pod(digest=A, name="maestrod-serving"):
    return {
        "metadata": {"name": name},
        "status": {
            "phase": "Running",
            "conditions": [{"type": "Ready", "status": "True"}],
            "containerStatuses": [
                {"name": "sidecar", "ready": True, "imageID": "helper@" + B},
                {"name": "maestrod", "ready": True, "imageID": "registry/maestrod@" + digest},
            ],
        },
    }


SHIM = '''
import json, os, pathlib, sys
root = pathlib.Path(os.environ["FIXTURE_DIR"])
name = pathlib.Path(sys.argv[0]).name
args = sys.argv[1:]
with (root / "calls").open("a") as log:
    log.write(json.dumps([name, *args]) + "\\n")
if name == "kubectl":
    if args[:2] == ["get", "deployment"]:
        print((root / "deployment.json").read_text())
    elif args[:2] == ["get", "pods"]:
        print((root / "pods.json").read_text())
    elif args[:2] == ["patch", "deployment"]:
        if os.environ.get("PATCH_CONFLICT"):
            sys.exit(1)
        (root / "patch.json").write_text(args[args.index("-p") + 1])
    else:
        raise RuntimeError(args)
elif name == "curl":
    if os.environ.get("HTTP_FAILURE"):
        if "--fail" in args:
            sys.exit(22)
        sys.stdout.buffer.write(b"HTTP/1.1 401 Unauthorized\\r\\n\\r\\n")
        sys.exit(0)
    sys.stdout.buffer.write((root / "headers").read_bytes())
elif name == "cat" and args == ["/registry-auth/.dockerconfigjson"]:
    print(json.dumps({"auths": {"registry.example": {"auth": "dGVzdDp0ZXN0"}}}))
else:
    raise RuntimeError([name, *args])
'''


class RestartJobTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.documents = render()
        cls.script = cls.documents["ConfigMap"]["data"]["run.sh"]

    def setUp(self):
        self.deployment = {
            "metadata": {"generation": 7, "resourceVersion": "42"},
            "spec": {"replicas": 1},
            "status": {"observedGeneration": 7, "replicas": 1,
                       "updatedReplicas": 1, "readyReplicas": 1,
                       "availableReplicas": 1},
        }
        self.pods = {"items": [pod()]}

    def run_script(self, registry=A, *, headers=None, **extra_env):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name in ("kubectl", "curl", "cat"):
                executable = root / name
                executable.write_text("#!" + sys.executable + "\n" + SHIM)
                executable.chmod(0o755)
            (root / "deployment.json").write_text(json.dumps(self.deployment))
            (root / "pods.json").write_text(json.dumps(self.pods))
            (root / "headers").write_text(
                headers if headers is not None else "HTTP/1.1 200 OK\r\nDocker-Content-Digest: " + registry + "\r\n"
            )
            result = subprocess.run(
                ["bash", "-c", self.script], capture_output=True, text=True,
                env={"PATH": str(root) + os.pathsep + os.environ["PATH"],
                     "FIXTURE_DIR": directory, "KUBECONFIG": "/dev/null", **extra_env},
            )
            calls = [json.loads(line) for line in (root / "calls").read_text().splitlines()]
            patch = json.loads((root / "patch.json").read_text()) if (root / "patch.json").exists() else None
            return result, calls, patch

    def assert_skipped(self):
        result, calls, patch = self.run_script(registry=B)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Skipping refresh:", result.stdout)
        self.assertIsNone(patch)
        self.assertFalse(any(call[0] == "curl" for call in calls))

    def test_unchanged_image_is_noop_and_uses_named_container(self):
        result, _, patch = self.run_script()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("No changes.", result.stdout)
        self.assertIsNone(patch)

    def test_new_publication_causes_one_resource_version_guarded_patch(self):
        result, calls, patch = self.run_script(registry=B)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(patch[0], {"op": "test", "path": "/metadata/resourceVersion", "value": "42"})
        self.assertEqual(patch[1]["path"], "/spec/template/metadata/annotations/nutrient~1refresh-tag")
        self.assertEqual(sum(call[:2] == ["kubectl", "patch"] for call in calls), 1)

    def test_incomplete_deployment_never_queries_registry(self):
        cases = [
            ("observedGeneration", 6), ("replicas", 2),
            ("updatedReplicas", 0), ("readyReplicas", 0), ("availableReplicas", 0),
        ]
        original = copy.deepcopy(self.deployment)
        for field, value in cases:
            with self.subTest(field=field):
                self.deployment = copy.deepcopy(original)
                self.deployment["status"][field] = value
                self.assert_skipped()
        self.deployment["status"] = {}
        self.assert_skipped()

    def test_scaled_to_zero_or_paused_is_skipped(self):
        self.deployment["spec"]["replicas"] = 0
        self.assert_skipped()
        self.deployment["spec"] = {"replicas": 1, "paused": True}
        self.assert_skipped()

    def test_first_start_with_empty_image_id_is_skipped(self):
        self.pods["items"][0]["status"]["containerStatuses"][1]["imageID"] = ""
        self.assert_skipped()

    def test_missing_or_unready_serving_container_is_skipped(self):
        self.pods["items"][0]["status"]["containerStatuses"][1]["ready"] = False
        self.assert_skipped()
        self.pods["items"][0]["status"]["containerStatuses"].pop()
        self.assert_skipped()

    def test_terminating_old_pod_blocks_refresh_even_if_status_looks_complete(self):
        old = pod()
        old["metadata"]["deletionTimestamp"] = "2026-10-14T10:00:00Z"
        self.pods["items"].append(old)
        self.assert_skipped()
        self.pods["items"] = [old]
        self.assert_skipped()

    def test_pending_or_unready_pod_is_skipped(self):
        self.pods["items"][0]["status"]["phase"] = "Pending"
        self.assert_skipped()
        self.pods["items"][0]["status"]["phase"] = "Running"
        self.pods["items"][0]["status"]["conditions"][0]["status"] = "False"
        self.assert_skipped()

    def test_empty_pod_list_is_skipped(self):
        self.pods["items"] = []
        self.assert_skipped()

    def test_mixed_serving_digests_refresh_to_registry_after_convergence(self):
        self.deployment["spec"]["replicas"] = 2
        self.deployment["status"].update(replicas=2, updatedReplicas=2, readyReplicas=2, availableReplicas=2)
        self.pods["items"].append(pod(B, "maestrod-serving-2"))
        for registry in (B, "sha256:" + "c" * 64):
            with self.subTest(registry=registry):
                result, calls, patch = self.run_script(registry=registry)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIsNotNone(patch)
                self.assertEqual(sum(call[:2] == ["kubectl", "patch"] for call in calls), 1)

    def test_finished_test_and_failed_serving_pods_do_not_block_refresh(self):
        failed = pod(B, "maestrod-evicted")
        failed["status"]["phase"] = "Failed"
        succeeded = {
            "metadata": {"name": "maestrod-test-connection"},
            "status": {"phase": "Succeeded", "containerStatuses": [
                {"name": "nc", "ready": False, "imageID": "busybox@" + B}
            ]},
        }
        self.pods["items"].extend([failed, succeeded])
        result, _, patch = self.run_script(registry=A)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("No changes.", result.stdout)
        self.assertIsNone(patch)
        result, _, patch = self.run_script(registry=B)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIsNotNone(patch)

    def test_terminal_pod_still_blocks_refresh_while_terminating(self):
        old = pod(B, "maestrod-terminating")
        old["status"]["phase"] = "Failed"
        old["metadata"]["deletionTimestamp"] = "2026-10-14T10:00:00Z"
        self.pods["items"].append(old)
        self.assert_skipped()

    def test_multiple_ready_pods_with_same_digest_are_noop(self):
        self.deployment["spec"]["replicas"] = 2
        self.deployment["status"].update(replicas=2, updatedReplicas=2, readyReplicas=2, availableReplicas=2)
        self.pods["items"].append(pod(A, "maestrod-serving-2"))
        result, _, patch = self.run_script()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("No changes.", result.stdout)
        self.assertIsNone(patch)

    def test_runtime_digest_without_repository_prefix_is_supported(self):
        self.pods["items"][0]["status"]["containerStatuses"][1]["imageID"] = "containerd://" + A
        result, _, patch = self.run_script()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("No changes.", result.stdout)
        self.assertIsNone(patch)

    def test_bad_registry_digest_is_skipped(self):
        for headers in ("HTTP/1.1 200 OK\r\n", "Docker-Content-Digest: invalid\r\n"):
            with self.subTest(headers=headers):
                result, _, patch = self.run_script(headers=headers)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn("registry did not return a valid digest", result.stdout)
                self.assertIsNone(patch)

    def test_redirect_uses_final_case_insensitive_digest_with_crlf_headers(self):
        headers = ("HTTP/1.1 301 Moved Permanently\r\nDocker-Content-Digest: " + A +
                   "\r\n\r\nHTTP/2 200 OK\r\ndOcKeR-CoNtEnT-DiGeSt: " + B + "\r\n\r\n")
        result, _, patch = self.run_script(headers=headers)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIsNotNone(patch)
        self.assertIn("Latest image:  " + B + "\n", result.stdout)

    def test_http_failure_cannot_trigger_rollout(self):
        result, _, patch = self.run_script(registry=B, HTTP_FAILURE="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIsNone(patch)

    def test_concurrent_deployment_change_cannot_trigger_rollout(self):
        result, _, patch = self.run_script(registry=B, PATCH_CONFLICT="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIsNone(patch)

    def test_b_is_deferred_until_a_has_finished(self):
        self.deployment["status"].update(replicas=2, updatedReplicas=1)
        self.assert_skipped()
        self.deployment["status"]["replicas"] = 1
        result, _, patch = self.run_script(registry=B)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIsNotNone(patch)

    def test_two_replica_rollout_defers_b_then_refreshes_mixed_a_and_b(self):
        self.deployment["spec"]["replicas"] = 2
        self.deployment["status"].update(replicas=3, updatedReplicas=2, readyReplicas=2, availableReplicas=2)
        starting = pod(B, "maestrod-starting")
        starting["status"]["containerStatuses"][1]["ready"] = False
        self.pods["items"].extend([pod(A, "maestrod-old"), starting])
        self.assert_skipped()
        self.deployment["status"]["replicas"] = 2
        self.pods["items"] = [pod(A, "maestrod-updated-1"), pod(B, "maestrod-updated-2")]
        result, calls, patch = self.run_script(registry=B)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIsNotNone(patch)
        self.assertEqual(sum(call[:2] == ["kubectl", "patch"] for call in calls), 1)
        self.pods["items"][0] = pod(B, "maestrod-updated-1")
        result, _, patch = self.run_script(registry=B)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("No changes.", result.stdout)
        self.assertIsNone(patch)

    def test_helper_labels_cannot_match_serving_selector(self):
        documents = render("--set", "podDisruptionBudget.create=true", "--set", "podDisruptionBudget.maxUnavailable=1",
                           "--set-json", 'restartJob.podLabels={"app.kubernetes.io/name":"maestrod","custom":"retained"}')
        selector = documents["Deployment"]["spec"]["selector"]["matchLabels"]
        self.assertEqual(selector, {"app.kubernetes.io/name": "maestrod", "app.kubernetes.io/instance": "maestrod"})
        labels = documents["CronJob"]["spec"]["jobTemplate"]["spec"]["template"]["metadata"]["labels"]
        self.assertEqual(labels["custom"], "retained")
        self.assertNotIn("app.kubernetes.io/name", labels)
        self.assertEqual(labels["app.kubernetes.io/component"], "restart-job")
        self.assertFalse(all(labels.get(key) == value for key, value in selector.items()))
        self.assertEqual(documents["PodDisruptionBudget"]["spec"]["selector"]["matchLabels"], selector)

    def test_disabled_refresh_renders_no_cronjob(self):
        self.assertNotIn("CronJob", render("--set", "restartJob.enabled=false"))


if __name__ == "__main__":
    unittest.main()
