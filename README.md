# Azure Virtual Desktop OpenTofu / Terraform Module

Module to set up AVD and related resources (network, vms etc.) - initially starting with AVD Personal.

We will probably add support for pooled in the future, but since we already have a working code for pooled using bicep and _— sigh, —_ CUE it's not a priority.

# OpenTufu?

[OpenTofu](https://opentofu.org/) is preferred over HashiCorp's Terraform for _[very](https://newsroom.ibm.com/2024-04-24-IBM-to-Acquire-HashiCorp-Inc-Creating-a-Comprehensive-End-to-End-Hybrid-Cloud-Platform)
[obvious](https://dev.to/rafaelherik/in-light-of-terraform-licensing-changes-opentofu-offers-a-free-open-source-path-26dc)
[reasons](https://meshedinsights.com/2021/02/02/rights-ratchet/)_.

That being said, this code will strive to be Terraform-compatible where possible. Any OpenTofu-specific features will be clearly marked as such by the file extensionn `.tofu`. instead of `.tf`.
