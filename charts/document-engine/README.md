# Document Engine Helm chart

- [Document Engine Helm chart](#document-engine-helm-chart)
  - [Using this repository](#using-this-repository)
  - [Installing Document Engine](#installing-document-engine)
  - [Upgrade](#upgrade)
  - [License](#license)
  - [Support, Issues and License Questions](#support-issues-and-license-questions)

> [!NOTE] [More on Document Engine](https://pspdfkit.com/cloud/document-engine/)

## Using this repository

```
helm repo add pspdfkit https://pspdfkit.github.io/helm-charts
helm repo update
```

## Installing Document Engine

```
helm upgrade --install --debug --dry-run \
     pspdfkit/document-engine \
     -n pspdfkit-services \
     -f ./document-engine-values.yaml
```

## Upgrade

> [!NOTE] Please consult the [changelog](/charts/document-engine/CHANGELOG.md)

## License

This software is licensed under a [modified BSD license](LICENSE).

## Support, Issues and License Questions

PSPDFKit offers support via https://pspdfkit.com/support/request/

Are you [evaluating our SDK](https://pspdfkit.com/try/)? That's great, we're happy to help out! To make sure this is fast, please use a work email and have someone from your company fill out our sales form: https://pspdfkit.com/sales/

