# Nutrient Helm Charts

> [!NOTE] 
> If you are looking for [Integrify](https://www.integrify.com/) Helm charts,
> please find them in the dedicated repository: https://github.com/Integrify/helm-charts

## Using this repository

```
helm repo add nutrient https://pspdfkit.github.io/helm-charts
helm repo update
```

## Installing Nutrient products

### Document Engine

```
helm upgrade --install -n document-engine \
     document-engine nutrient/document-engine \
     -f ./document-engine-values.yaml
```

## Support, Issues and License Questions

Nutrient offers support via https://support.nutrient.io/hc/en-us/requests/new

Are you [evaluating our SDK](https://www.nutrient.io/sdk/)? That's great, we're happy to help out! To make sure this is fast, please use a work email and have someone from your company fill out our sales form: https://www.nutrient.io/contact-sales/

## License

This software is licensed under a [modified BSD license](LICENSE)
