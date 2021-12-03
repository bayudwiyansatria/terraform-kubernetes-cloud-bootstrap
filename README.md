![Platforms](https://img.shields.io/badge/%20Platforms-Windows%20/%20Linux-blue.svg?style=flat-square")
[![License](https://img.shields.io/badge/%20Licence-MIT-green.svg?style=flat-square)](LICENSE.md)
[![Code Of Conduct](https://img.shields.io/badge/Community-Code%20of%20Conduct-orange.svg?style=flat-squre)](CODE_OF_CONDUCT.md)
[![Support](https://img.shields.io/badge/Community-Support-red.svg?style=flat-square)](SUPPORT.md)
[![Contributing](https://img.shields.io/badge/%20Community-Contribution-yellow.svg?style=flat-square)](CONTRIBUTING.md)

<hr>

# Terraform Kubernetes

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v1.4%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md)

Kubernetes provisioner using terraform. Installing kubernetes stack on cloud with
External [Cloud Provider](https://github.com/kubernetes/cloud-provider).

## Requirements

| Name | Version |
| ---- | ------- |
| [Terraform](https://www.terraform.io/downloads.html) |  > = 1.0.11 |

Machine at least 3 with minum as kubernetes requirements refer to
kubernetes [docs](https://kubernetes.io/docs/setup/production-environment)

## Getting Started

There are instructions under `demo` directory will get you a copy of the project up and running on your local machine
for development and testing purposes.

### Usage

```shell
module "kubernetes" {
  source          = "bayudwiyansatria/bootstrap/kubernetes"
  master_host     = var.master_host
  worker_host     = var.worker_host
  ssh_private_key = var.cluster_admin_ssh_access
}
```

```shell
module "kubernetes" {
  source          = "bayudwiyansatria/bootstrap/kubernetes"
  master_host     = [
    10.0.0.2
  ]
  worker_host     = [
    10.0.0.3,
    10.0.0.4
  ]
  ssh_private_key = var.cluster_admin_ssh_access
}
```

### Variables

| Name | Default | Description | Required |
| ---- | ------- | ----------- | -------- |
| master_host | `[]` | List Server IP addresses for Master | true |
| worker_host | `[]` | List Server IP addresses for Master | true |
| ssh_private_key | `""` | SSH Private Key | true |
| kubernetes_version | `1.20.0` | Kubernetes Version | false |
| feature_gates | `""` | Kubernetes feature gate | false |
| pod_network_cidr | `192.168.0.0/16` | Pod Network CIDR | false |
| docker_enabled | `true` | Provisioning Docker Engine | false |

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

Looking to contribute to our code but need some help? There's a few ways to get information:

* Connect with us on [Twitter](https://twitter.com/bayudsatria)
* Like us on [Facebook](https://facebook.com/PBayuDSatria)
* Follow us on [LinkedIn](https://linkedin.com/in/bayudwiyansatria)
* Subscribe us on [Youtube](https://youtube.com/channel/UCihxWj1rtheK73mGdrf0OiA)
* Log an issue here on github

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see
the [tags on this repository](https://github.com/bayudwiyansatria/Development-And-Operations/tags).

## Authors

- [Bayu Dwiyan Satria](https://github.com/bayudwiyansatria)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

<p> Copyright &copy; 2021. All Rights Reserved.

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
