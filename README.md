# PSPDFKit Helm Charts

> [!NOTE] If you are looking for [Integrify](https://www.integrify.com/) Helm charts,
> please find them in the dedicated repository: https://github.com/Integrify/helm-charts

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

### Integrify

If you are looking for Integrify helm charts, they are hoste