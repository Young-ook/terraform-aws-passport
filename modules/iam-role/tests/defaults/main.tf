terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "main" {
  for_each = toset(["null", "security"])
  source   = "../.."
  name     = each.key == "null" ? null : each.key
}

resource "test_assertions" "pet_name" {
  component = "pet_name"
  check "pet_name" {
    description = "default random pet name"
    condition   = can(regex("^role", module.main["null"].role.name))
  }
}

resource "test_assertions" "role_name" {
  component = "custom_name"
  check "pet_name" {
    description = "custom role name"
    condition   = can(regex("^security", module.main["security"].role.name))
  }
}
