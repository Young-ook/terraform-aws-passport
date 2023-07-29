terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "main" {
  for_each = toset(["null", "joe"])
  source         = "../.."
  name           = each.key == "null" ? null : each.key
}

resource "test_assertions" "pet_name" {
  component = "pet_name"
  check "pet_name" {
    description = "default random pet name"
    condition   = can(regex("^usr", module.main["null"].user.name))
  }
}

resource "test_assertions" "user_name" {
  component = "custom_name"
  check "pet_name" {
    description = "custom user name"
    condition   = can(regex("^joe", module.main["joe"].user.name))
  }
}
