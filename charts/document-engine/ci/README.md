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
* `03-cnpg-s3-redis-values.yaml`
  * PostgreSQL
  * MinIO as S3 asset storage backend through MinIO operator
  * Redis for rendering cache as a sidecar container
* `04-cnpg-azure-values.yaml`
  * PostgreSQL
  * Azurite to test Azure Blob storage
* `10-env-variables-values.yaml`
  * Very blunt environment variables setting, an easy migration from Docker compose
