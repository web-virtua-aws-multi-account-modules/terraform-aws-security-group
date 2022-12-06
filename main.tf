locals {
  security_list = flatten([
    for item in var.allow_rules_list : [
      for port_range in item.ports : [length(split(",", trimspace(tostring(port_range)))) == 1 ? [
        {
          from_port        = port_range
          to_port          = port_range
          protocol         = item.protocol
          cidr_blocks      = try(item.cidr_blocks, null) != null ? item.cidr_blocks : var.allow_ips_security_groups != null ? var.allow_ips_security_groups : var.default_cidr_blocks
          ipv6_cidr_blocks = item.ipv6_cidr_blocks
          prefix_list_ids  = item.prefix_list_ids
          security_groups  = item.security_groups
          self             = item.self
          description      = item.description
        }] : [
        {
          from_port        = tonumber(split(",", replace(port_range, " ", ""))[0])
          to_port          = tonumber(split(",", replace(port_range, " ", ""))[1])
          protocol         = item.protocol
          cidr_blocks      = try(item.cidr_blocks, null) != null ? item.cidr_blocks : var.allow_ips_security_groups != null ? var.allow_ips_security_groups : var.default_cidr_blocks
          ipv6_cidr_blocks = item.ipv6_cidr_blocks
          prefix_list_ids  = item.prefix_list_ids
          security_groups  = item.security_groups
          self             = item.self
          description      = item.description
        }]
      ]
    ]
  ])
}

resource "aws_security_group" "create_security_group" {
  name        = var.name
  vpc_id      = var.vpc_id
  description = var.description_security

  dynamic "ingress" {
    for_each = contains(["stateful", "ingress"], var.group_type) ? local.security_list : []
    content {
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
      prefix_list_ids  = ingress.value.prefix_list_ids
      security_groups  = ingress.value.security_groups
      self             = ingress.value.self
      description      = try(ingress.value.description, var.description_rule)
    }
  }

  dynamic "egress" {
    for_each = contains(["stateful", "egress"], var.group_type) ? local.security_list : []
    content {
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
      prefix_list_ids  = egress.value.prefix_list_ids
      security_groups  = egress.value.security_groups
      self             = egress.value.self
      description      = try(egress.value.description, var.description_rule)
    }
  }

  tags = merge(var.tags, {
    Name                = var.name
    "tf-security-group" = var.name
  })
}
