"""Run with: python -m unittest discover -s tests -v (requires Helm, PyYAML).

Render the Document Engine Secret for each way of configuring Azure Blob
Storage and check which Azure variables it holds.
"""

import base64
from pathlib import Path
import subprocess
import unittest

import yaml

ROOT = Path(__file__).resolve().parents[1]
AZURE_KEYS = {
    "AZURE_STORAGE_ACCOUNT_NAME",
    "AZURE_STORAGE_ACCOUNT_KEY",
    "AZURE_STORAGE_ACCOUNT_CONNECTION_STRING",
}


def azure_secret_data(**azure):
    args = ["--set", "assetStorage.backendType=azure",
            "--set", "assetStorage.azure.container=documents"]
    for key, value in azure.items():
        args += ["--set-string", f"assetStorage.azure.{key}={value}"]
    output = subprocess.check_output(
        ["helm", "template", "de", str(ROOT / "charts/document-engine"),
         "--show-only", "templates/secret.yaml", *args], text=True,
    )
    data = yaml.safe_load(output)["data"]
    return {k: base64.b64decode(v).decode() for k, v in data.items() if k in AZURE_KEYS}


class AzureSecretTest(unittest.TestCase):
    def test_account_name_and_key(self):
        self.assertEqual(
            azure_secret_data(accountName="acct", accountKey="key"),
            {"AZURE_STORAGE_ACCOUNT_NAME": "acct", "AZURE_STORAGE_ACCOUNT_KEY": "key"},
        )

    def test_connection_string(self):
        self.assertEqual(
            azure_secret_data(connectionString="cs"),
            {"AZURE_STORAGE_ACCOUNT_CONNECTION_STRING": "cs"},
        )

    def test_connection_string_takes_priority(self):
        self.assertEqual(
            azure_secret_data(connectionString="cs", accountName="acct", accountKey="key"),
            {"AZURE_STORAGE_ACCOUNT_CONNECTION_STRING": "cs"},
        )

    def test_account_name_only(self):
        self.assertEqual(
            azure_secret_data(accountName="acct"),
            {"AZURE_STORAGE_ACCOUNT_NAME": "acct"},
        )

    def test_account_key_only_writes_nothing(self):
        self.assertEqual(azure_secret_data(accountKey="key"), {})

    def test_external_secret_writes_nothing(self):
        self.assertEqual(
            azure_secret_data(accountName="acct", accountKey="key", externalSecretName="ext"),
            {},
        )


if __name__ == "__main__":
    unittest.main()
