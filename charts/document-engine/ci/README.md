# Tests

* `1-no-storage-values.yaml`
  * No storage, processing only
* `2-with-db-clustering-values.yaml`
  * PostgreSQL database using Bitnami chart
  * Clustering is enabled
  * Prometheus endpoint and related resources are enabled
  * Cleanup job is created
* `3-with-db-s3-redis-values.yaml`
  * PostgreSQL
  * MinIO as S3 asset storage backend
  * Redis for rendering cache
* `4-with-db-azure-values.yaml`
  * PostgreSQL
  * Azurite to test Azure Blob storage
  * Exporting metrics in StatsD format, using Prometheus exporter sidecar as a receiver
* `10-envFrom-values.yaml`
  * Very blunt environment variables setting, an easy migration from Docker compose
