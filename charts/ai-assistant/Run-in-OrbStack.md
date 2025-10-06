# Quickly get AI Assistant running in OrbStack

## Prerequisites

CloudNativePG and Ingress controller: 

```shell
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg --namespace cnpg-system --create-namespace cnpg/cloudnative-pg
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
```

## Installation from Helm repository

Helm repository: 

```shell
helm repo add nutrient https://pspdfkit.github.io/helm-charts
```

Starting values:

```shell
curl https://raw.githubusercontent.com/PSPDFKit/helm-charts/refs/heads/master/charts/document-engine/values.simple.yaml -o /tmp/aia-simple-values.yaml
```

Installation:

```shell
helm upgrade --install --namespace aia --create-namespace aia nutrient/ai-assistant \
  -f /tmp/aia-simple-values.yaml \
  --set document-engine.cloudNativePG.clusterSpec.storage.size=128Mi \
  --set document-engine.cloudNativePG.clusterSpec.storage.storageClass=local-path \
  --set cloudNativePG.clusterSpec.storage.size=128Mi \
  --set cloudNativePG.clusterSpec.storage.storageClass=local-path \
  --set "document-engine.ingress.hosts[0].host=aia-de.k8s.orb.local" \
  --set "ingress.hosts[0].host=aia.k8s.orb.local"
```

## Installation from the local copy

From the chart directory:

```shell
helm upgrade --install --namespace aia --create-namespace aia . \
  -f values.simple.yaml \
  --set document-engine.cloudNativePG.enabled=true \
  --set document-engine.cloudNativePG.clusterSpec.storage.size=128Mi \
  --set document-engine.cloudNativePG.clusterSpec.storage.storageClass=local-path \
  --set cloudNativePG.clusterSpec.storage.size=128Mi \
  --set cloudNativePG.clusterSpec.storage.storageClass=local-path \
  --set "document-engine.ingress.hosts[0].host=aia-de.k8s.orb.local" \
  --set "ingress.hosts[0].host=aia.k8s.orb.local"
```
