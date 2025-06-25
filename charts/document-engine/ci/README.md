# Tests

* `1-no-storage-values.yaml` — Document Engine with no storage, processing only
* `2-with-db-values.yaml` — Basic configuration with PostgreSQL database
* `3-with-db-s3-redis-values.yaml` — PostgreSQL, MinIO as S3 asset storage backend and Redis for rendering cache
* `4-with-db-azure-values.yaml` — PostgreSQL and Azurite to test Azure Blob storage
* `10-envFrom-values.yaml` — blunt environment variables setting, an easy migration from Docker compose
