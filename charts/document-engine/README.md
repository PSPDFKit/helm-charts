# Document Engine Helm chart

- [Document Engine Helm chart](#document-engine-helm-chart)
  - [Using this repository](#using-this-repository)
  - [Installing Document Engine](#installing-document-engine)
    - [Dependencies](#dependencies)
    - [Upgrade](#upgrade)
  - [Contribution](#contribution)
  - [License](#license)
  - [Support, Issues and License Questions](#support-issues-and-license-questions)

> [!NOTE] 
> [More on Document Engine](https://pspdfkit.com/cloud/document-engine/)

## Using this repository

```
helm repo add pspdfkit https://pspdfkit.github.io/helm-charts
helm repo update
```

## Installing Document Engine

```shell
helm upgrade --install \
     document-engine pspdfkit/document-engine \
     -n pspdfkit-services \
     -f ./document-engine-values.yaml
```

### Dependencies

The chart depends upon [Bitnami](https://github.com/bitnami/charts/tree/main/bitnami) charts for PostgreSQL, [MinIO](https://min.io/) and [Redis](https://redis.io/). They are disabled by default, but can be enabled for convenience. Please consider [tests](/charts/document-engine/ci) as examples.

### Upgrade

> [!NOTE] 
> Please consult the [changelog](/charts/document-engine/CHANGELOG.md)

## Contribution

The chart is validated using [ct](https://github.com/helm/chart-testing/tree/main) [lint](https://github.com/helm/chart-testing/blob/main/doc/ct_lint.md):

```shell
ct lint --target-branch "$(git rev-parse --abbrev-ref HEAD)"
```

## License

This software is licensed under a [modified BSD license](LICENSE).

## Support, Issues and License Questions

PSPDFKit offers support via https://pspdfkit.com/support/request/

Are you [evaluating our SDK](https://pspdfkit.com/try/)? That's great, we're happy to help out! To make sure this is fast, please use a work email and have someone from your company fill out our sales form: https://pspdfkit.com/sales/

