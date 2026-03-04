# Tests

* `00-simple.yaml`
  * The chart `values.simple.yaml`
* `01-no-storage.yaml`
  * No storage, processing only
* `02-cnpg-clustering-values.yaml`
  * PostgreSQL database — CloudNativePG Cluster
  * Clustering is enabled
  * Prometheus endpoint and related resources are enabled
  * Cleanup job is created
  * StatefulSet workload type with persistent volume claims
  * Gateway API HTTPRoute with custom rules
* `03-cnpg-s3-redis-values.yaml`
  * PostgreSQL
  * MinIO as S3 asset storage backend through MinIO operator
  * Redis for rendering cache as a sidecar container
  * `gateway.extraHTTPRoutes` for dashboard
* `04-cnpg-azure-values.yaml`
  * PostgreSQL
  * Azurite to test Azure Blob storage
  * Ingress (nginx)
* `05-envoy-sidecar-values.yaml`
  * Envoy sidecar for consistent hashing by document ID
  * Multiple replicas (2) to test hash distribution
  * Envoy admin endpoint exposed for metrics
  * Network policy enabled to test Envoy port access
  * Headless service for pod discovery
  * StatefulSet workload type with persistent volume claims
  * Ingress (nginx)
* `10-env-variables-values.yaml`
  * Very blunt environment variables setting, an easy migration from Docker compose
