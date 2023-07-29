terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "main" {
  for_each = toset(["null", "cost-center"])
  source         = "../.."
  name           = each.key == "null" ? null : each.key
}

resource "test_assertions" "pet_name" {
  component = "pet_name"
  check "pet_name" {
    description = "default random pet name"
    condition   = can(regex("^grp", module.main["null"].group.name))
  }
}

resource "test_assertions" "user_name" {
  component = "pet_name"
  check "pet_name" {
    description = "custom user name"
    condition   = can(regex("^cost-center", module.main["cost-center"].group.name))
  }
}
