# Changelog

- [Changelog](#changelog)
  - [1.1.0 (2026-02-28)](#110-2026-02-28)
    - [Added](#added)
    - [Changed](#changed)
  - [1.0.0 (2026-01-20)](#100-2026-01-20)
    - [Changed](#changed-1)
  - [0.4.0 (2025-11-7)](#040-2025-11-7)
    - [Changed](#changed-2)
  - [0.3.0 (2025-10-04)](#030-2025-10-04)
    - [Added](#added-1)
    - [Changed](#changed-3)
  - [0.2.0 (2025-07-04)](#020-2025-07-04)
    - [Added](#added-2)
    - [Changed](#changed-4)
  - [0.1.0 (2025-06-17)](#010-2025-06-17)
    - [Changed](#changed-5)
  - [0.0.13 (2025-06-10)](#0013-2025-06-10)
    - [Changed](#changed-6)
  - [0.0.12 (2025-06-10)](#0012-2025-06-10)
    - [Changed](#changed-7)
  - [0.0.10 (2025-06-9)](#0010-2025-06-9)
    - [Changed](#changed-8)
  - [0.0.1 (2025-05-28)](#001-2025-05-28)
    - [Added](#added-3)
## 1.2.0 (2026-03-05)

### Changed

* [AI Assistant 2.1.0](https://www.nutrient.io/guides/ai-assistant/changelog/#2.1.0)

## 1.1.0 (2026-02-28)

### Added

* Gateway API support under `gateway.*` for creating [HTTPRoute](https://gateway-api.sigs.k8s.io/api-types/httproute/) resources as an alternative to Ingress
* Optional chart-managed [Gateway](https://gateway-api.sigs.k8s.io/api-types/gateway/) resource via `gateway.gateway.*`
* HTTPRoute `parentRefs` auto-wiring to the chart-managed Gateway when `gateway.gateway.enabled=true` and `gateway.parentRefs` is empty

### Changed

* Document Engine dependency updated
* Autoscaling: no dewfault CPU and memory target values, for more flexibility

## 1.0.0 (2026-01-20)

### Changed

* [AI Assistant 2.0.1](https://www.nutrient.io/guides/ai-assistant/changelog/#2.0.1)

## 0.4.0 (2025-11-7)

### Changed

* [AI Assistant 1.6.0](https://www.nutrient.io/guides/ai-assistant/changelog/#1.6.0)

## 0.3.0 (2025-10-04)

### Added

* `cloudNativePG` section, including `cloudNativePG.cluster` to create PostgreSQL database clusters using [CloudNativePG](https://cloudnative-pg.io/) operator.

### Changed

* Removed `postgresql` Bitnami chart dependency, and the corresponding section in the values file.

## 0.2.0 (2025-07-04)

### Added

* Minimal CI testing

### Changed

* [AI Assistant 1.5.0](https://www.nutrient.io/guides/ai-assistant/changelog/#1.5.0)
* Document Engine dependency

## 0.1.0 (2025-06-17)

### Changed

* [AI Assistant 1.4.0](https://www.nutrient.io/guides/ai-assistant/changelog/#1.4.0)

## 0.0.13 (2025-06-10)

### Changed

* Document Engine chart dependency

## 0.0.12 (2025-06-10)

### Changed

* Changelog corrections
* Document Engine dependency

## 0.0.10 (2025-06-9)

### Changed

* Cleanups and fixes of early development

## 0.0.1 (2025-05-28)

### Added

* Initial state
