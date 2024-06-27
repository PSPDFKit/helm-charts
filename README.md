# PSPDFKit Helm Charts

## Using this repository

```
helm repo add pspdfkit https://pspdfkit.github.io/helm-charts
helm repo update
```

## Installing PDPDFKit tools

### Document Engine

```
helm upgrade --install --debug --dry-run \
     pspdfkit/document-engine \
     -n pspdfkit-services \
     -f ./document-engine-values.yaml
```
