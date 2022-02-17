locals {
  vpcs = {
    ingress = {
      cidr    = "10.10.0.0/16"
      vpc     = "module.ingress.vpc.id"
      subnets = "values(module.ingress.subnets.private)"
      routes = [
        {
          destination_cidr_block = "10.20.0.0/16"
        },
        {
          blackhole              = true
          destination_cidr_block = "0.0.0.0/0"
        },
      ]
    }
    egress = {
      cidr    = "10.20.0.0/16"
      vpc     = "module.egress.vpc.id"
      subnets = "values(module.egress.subnets.public)"
      routes = [
        {
          destination_cidr_block = "10.10.0.0/16"
        },
      ]
    }
    corp = {
      cidr                                            = "172.16.0.0/16"
      vpc                                             = "module.corp.vpc.id"
      subnets                                         = "values(module.corp.subnets.private)"
      transit_gateway_default_route_table_propagation = false
      transit_gateway_default_route_table_association = false
      routes = [
        {
          blackhole              = true
          destination_cidr_block = "10.10.0.0/16"
        },
        {
          destination_cidr_block = "10.20.10.10/32"
        },
      ]
    }
  }

  vpc_attachments_with_routes = [
    for e in chunklist(
      flatten([
        for k, v in local.vpcs : setproduct([{ vpc = k }], v["routes"]) if length(lookup(v, "routes", {})) > 0
      ]),
    2) : merge(e[0], e[1])
  ]

  vpc_attachments_without_default_route_table_association = {
    for k, v in local.vpcs : k => v if !lookup(v, "transit_gateway_default_route_table_association", true)
  }

  vpc_attachments_without_default_route_table_propagation = {
    for k, v in local.vpcs : k => v if !lookup(v, "transit_gateway_default_route_table_propagation", true)
  }
}

output "vpcs_with_routes" {
  value = local.vpc_attachments_with_routes
}

output "vpc_attachments_without_default_route_table_association" {
  value = local.vpc_attachments_without_default_route_table_association
}

output "vpc_attachments_without_default_route_table_propagation" {
  value = local.vpc_attachments_without_default_route_table_propagation
}

locals {
  nodes = [
    {
      name          = "default"
      instance_type = "t3.small"
    },
    {
      name          = "al2"
      instance_type = "t3.small"
      ami_type      = "AL2_x86_64"
    },
    {
      name          = "bottlerocket"
      instance_type = "t3.small"
      ami_type      = "BOTTLEROCKET_x86_64"
    },
    {
      name          = "al2-gpu"
      instance_type = "g4dn.xlarge"
      ami_type      = "AL2_x86_64_GPU"
    },
    {
      name          = "al2-arm"
      instance_type = "m6g.medium"
      ami_type      = "AL2_ARM_64"
    },
  ]
}

output "nodes_sorted_by_name" {
  value = {
    for n in local.nodes : n.name => n
  }
}

output "empty_list_for_each" {
  value = { for k, v in [] : k => v }
}
