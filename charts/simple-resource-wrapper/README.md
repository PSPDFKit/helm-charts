# Direct wrapper of Kubernetes resources to use with Terraform

This chart just takes any resource, provided as values and installs it as Helm release.

It serves to work around Terraform limitation with custom resources through manifests that requires Kubernetes API to be available on planning stage.

## Protecting from removal upon Helm operations

In order to keep resources when Helm release is deleted or recreated or when Flux gitOps is feeling strange, include the following annotations:

```yaml
  annotations:
    kustomize.toolkit.fluxcd.io/prune: "disabled"
    helm.sh/resource-policy: keep
```
