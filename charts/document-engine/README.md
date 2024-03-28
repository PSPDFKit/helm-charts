# Document Engine Helm chart

- [Document Engine Helm chart](#document-engine-helm-chart)
  - [Upgrade](#upgrade)
    - [From 1.1.x to 2.0.0](#from-11x-to-200)
  - [License](#license)
  - [Support, Issues and License Questions](#support-issues-and-license-questions)

[More on Document Engine](https://pspdfkit.com/cloud/document-engine/)

## Upgrade

### From 1.1.x to 2.0.0

* No more `createSecret` values, condition for creating secret by the chart are moved into definition of the corresponding external secret names.
* Storage parameters are now expected to fully reside in `Secret` resources
  * `pspdfkit.storage.postgres.auth`, `pspdfkit.storage.s3.auth`, `pspdfkit.storage.redis.auth` maps were all merged into the corresponding `pspdfkit.storage` higher level maps
  * Redis secret is now expected to contain (if existsis) all Redis parameters, not only the password

## License

This software is licensed under a [modified BSD license](LICENSE).

## Support, Issues and License Questions

PSPDFKit offers support via https://pspdfkit.com/support/request/

Are you [evaluating our SDK](https://pspdfkit.com/try/)? That's great, we're happy to help out! To make sure this is fast, please use a work email and have someone from your company fill out our sales form: https://pspdfkit.com/sales/

