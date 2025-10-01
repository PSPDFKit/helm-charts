# Tests

* `00-simple.yaml`
  * The chart `values.simple.yaml`
* `01-no-storage.yaml`
  * No storage, processing only
* `02-cnpg-clustering.yaml`
  * PostgreSQL database — CloudNativePG Cluster
  * Clustering is enabled
  * Prometheus endpoint and related resources are enabled
  * Cleanup job is created
* `03-cnpg-s3-redis.yaml`
  * PostgreSQL
  * MinIO as S3 asset storage backend through MinIO operator
  * Redis for rendering cache as a sidecar container
* `04-cnpg-azure.yaml`
  * PostgreSQL
  * Azurite to test Azure Blob storage
  * Exporting metrics in StatsD format, using Prometheus exporter sidecar as a receiver
* `10-env-variables.yaml`
  * Very blunt environment variables setting, an easy migration from Docker compose
