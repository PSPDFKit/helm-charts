# PSPDFKit Helm Charts

> [!NOTE] 
> If you are looking for [Integrify](https://www.integrify.com/) Helm charts,
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

## Support, Issues and License Questions

PSPDFKit offers support for customers with an active SDK license via https://pspdfkit.com/support/request/

Are you [evaluating our SDK](https://pspdfkit.com/try/)? That's great, we're happy to help out! To make sure this is fast, please use a work email and have someone from your company fill out our sales form: https://pspdfkit.com/sales/

## License

This software is licensed under a [modified BSD license](LICENSE)
