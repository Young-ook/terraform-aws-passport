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
      policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
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
      policy_arns   = ["arn:aws:iam::aws:policy/S3FullAccess"]
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

locals {
  role_policy_list = chunklist(flatten([
    for k, v in local.nodes : setproduct([v.name], v.policy_arns) if length(lookup(v, "policy_arns", [])) > 0
  ]), 2)
}

output "policies_per_node_role" {
  value = [for p in local.role_policy_list : { role = p[0], policy = p[1] }]
}

locals {
  sagemaker_lifecycle_config_selection = ["hello", "hi"]
  sagemaker_lifecycle_config_list = {
    hello = {
      arn                              = "aws:arn:sagemaker:ap-northeast-2:hello"
      id                               = "ZWNoby"
      studio_lifecycle_config_app_type = "JupyterServer"
      studio_lifecycle_config_content  = "ZWNobyBoZWxsbw=="
      studio_lifecycle_config_name     = "hello"
    }
    hi = {
      arn                              = "aws:arn:sagemaker:ap-northeast-2:hi"
      id                               = "ZWNoby"
      studio_lifecycle_config_app_type = "JupyterServer"
      studio_lifecycle_config_content  = "ZWNobyBoZWxsbw=="
      studio_lifecycle_config_name     = "hi"
    }
    haha = {
      arn                              = "aws:arn:sagemaker:ap-northeast-2:haha"
      id                               = "ZWNoby"
      studio_lifecycle_config_app_type = "KernelGateway"
      studio_lifecycle_config_content  = "ZWNobyBoZWxsbw=="
      studio_lifecycle_config_name     = "haha"
    }
    yellow = {
      arn                              = "aws:arn:sagemaker:ap-northeast-2:yellow"
      id                               = "ZWNoby"
      studio_lifecycle_config_app_type = "KernelGateway"
      studio_lifecycle_config_content  = "ZWNobyBoZWxsbw=="
      studio_lifecycle_config_name     = "yellow"
    }
  }
}

output "sagemaker_lifecycle_config_arns" {
  value = { for k, v in local.sagemaker_lifecycle_config_list : k => v.arn }
}

output "sagemaker_lifecycle_config_selection" {
  value = { for k in local.sagemaker_lifecycle_config_selection : k => { for k, v in local.sagemaker_lifecycle_config_list : k => v.arn }[k] }
}
