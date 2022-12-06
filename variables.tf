variable "name" {
  description = "Name to security group"
  type    = string
}

variable "vpc_id" {
  description = "VPC ID to security group"
  type    = string
}

variable "group_type" {
  description = "Type of security group, can be ingress, egress or stateful, if selected stateful will be enable the same rules for ingress and egress"
  type    = string
  default = "stateful"
}

variable "description_security" {
  description = "Description to security group"
  type    = string
  default = "Default description"
}

variable "description_rule" {
  description = "Description to all security group rules if not exists description individual rule"
  type    = string
  default = "Default description rule"
}

variable "allow_ips_security_groups" {
  description = "IP's list to allow if not set individual cidr blocks"
  type        = list(string)
  default     = null
}

variable "default_cidr_blocks" {
  description = "Default cidr blocks if not set any cidr blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allow_rules_list" {
  description = "List with security groups rules configuration"
  type = list(object({
    protocol         = string
    ports            = list(any)
    cidr_blocks      = optional(list(string), null)
    ipv6_cidr_blocks = optional(list(string), null)
    prefix_list_ids  = optional(list(string), null)
    security_groups  = optional(list(string), null)
    self             = optional(bool, false)
    description      = optional(string, "Default description")
  }))
  default = [
    {
      protocol : "-1",
      cidr_blocks = ["0.0.0.0/0"],
      ipv6_cidr_blocks = ["::/0"]
      ports       = [0]
    },
    {
      protocol : "icmp",
      cidr_blocks = ["0.0.0.0/0"],
      ipv6_cidr_blocks = ["::/0"]
      ports       = ["-1"]
    }
  ]
}

variable "tags" {
  description = "Tags to security groups"
  type        = map(any)
  default     = {}
}
