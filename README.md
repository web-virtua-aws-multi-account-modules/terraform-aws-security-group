# AWS security groups for multiples accounts and regions with Terraform module
* This module simplifies creating and configuring security groups across multiple accounts and regions on AWS

* Is possible use this module with one region using the standard profile or multi account and regions using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Create file versions.tf with the exemple code below:
```hcl
terraform {
  required_version = ">= 1.3.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}
```

* Criate file provider.tf with the exemple code below:
```hcl
provider "aws" {
  alias   = "alias_profile_a"
  region  = "us-east-1"
  profile = "my-profile"
}

provider "aws" {
  alias   = "alias_profile_b"
  region  = "us-east-2"
  profile = "my-profile"
}
```


## Features enable of security groups configurations for this module:

- Security groups
- Ingress or Egress

## Usage exemples

### Security group of type ingress with allow_ips_security_groups variable allowed IP's list

```hcl
module "security_group_test" {
  source                      = "web-virtua-aws-multi-account-modules/security-group/aws"
  vpc_id                      = var.vpc_id
  name                        = "tf-allow-sg"
  group_type                  = "ingress"
  description_security        = "Ingress description"
  allow_rules_list            = var.allow_ingress_config
  allow_ips_security_groups   = var.allow_ips

  providers = {
    aws = aws.alias_profile_b
  }
}
```

### Security group of type egress

```hcl
module "security_group_test" {
  source               = "web-virtua-aws-multi-account-modules/security-group/aws"
  vpc_id               = var.vpc_id
  name                 = "tf-allow-sg"
  group_type           = "egress"
  description_security = "Egress description"
  allow_rules_list     = var.allow_egress_config

  providers = {
    aws = aws.alias_profile_b
  }
}
```

### Security group of type stateful, the same rules to ingress and egress

```hcl
module "security_group_test" {
  source               = "web-virtua-aws-multi-account-modules/security-group/aws"
  vpc_id               = var.vpc_id
  name                 = "tf-allow-sg"
  description_security = "Statefull description"
  allow_rules_list     = var.allow_stateful_config

  providers = {
    aws = aws.alias_profile_a
  }
}
```

## Variables
| Name | Type | Default | Required | Description | Options |
|------|-------------|------|---------|:--------:|:--------|
| name | `string` | `-` | yes | Name to security group | `-` |
| vpc_id | `string` | `-` | yes | VPC ID to security group | `-` |
| group_type | `string` | `stateful` | no | Type of security group, can be ingress, egress or stateful, if selected stateful will be enable the same rules for ingress and egress | `*`ingress <br> `*`egress<br> `*`stateful |
| description_security | `string` | `Default description` | no | Description to security group | `-` |
| description_rule | `string` | `Default description rule` | no | Description to all security group rules if not exists description individual rule | `-` |
| allow_ips_security_groups | `list(string)` | `null` | no | IP's list to allow if not set individual cidr blocks | `-` |
| default_cidr_blocks | `list(string)` | `["0.0.0.0/0"]` | no | Default cidr blocks if not set any cidr blocks | `-` |
| allow_rules_list | `list(object({})` | `object` | no | List with security groups rules configuration | `-` |
| tags | `map(any)` | `{}` | no | Tags to bucket | `-` |

* Model of variable allow_rules_list

1. The ports variable receive a list of the numbers or strings, in the case of using strings, you can set a range of ports comma separated, for example "5672, 5675" that allow a rule from port 5672 up to port 5675.
2. The cidr_blocks variable is optional, if setup will be used, if not setup will be used the allow_ips_security_groups variable and if both not setup will se used default_cidr_blocks variable.

```hcl
variable "allow_ingress" {
  type = list(object({
    protocol         = string
    ports            = list(any)
    cidr_blocks      = optional(list(string), null)
    ipv6_cidr_blocks = optional(list(string), null)
    prefix_list_ids  = optional(list(string), null)
    security_groups  = optional(list(string), null)
    self             = optional(bool, false)
    description      = optional(string, "Rule description")
  }))
  default = [
    {
      protocol : "tcp",
      ports = [
        22
      ]
    },
    {
      protocol : "tcp",
      cidr_blocks = ["0.0.0.0/0"],
      ports = [
        80, 443, "5672, 5673"
      ]
    },
    {
      protocol : "icmp",
      cidr_blocks = [
        "55.52.54.22/32",
        "55.52.45.34/32"
      ],
      ports = ["-1"]
    }
  ]
}
```


## Resources

| Name | Type |
|------|------|
| [aws_security_group.create_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Outputs

| Name | Description |
|------|-------------|
| `security_group` | All informations of the security group |
| `security_group_id` | Security group ID |
| `security_group_arn` | Security group ARN |
| `security_group_egress_rules` | Security group egress rules |
| `security_group_ingress_rules` | Security group ingress rules |
