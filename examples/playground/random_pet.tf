module "null" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = "2.2.6"
}

module "frigga" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = "2.2.6"
  name    = "hello"
  stack   = "frigga"
  detail  = "name"
  petname = false
}

module "myname" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = "2.2.6"
  name    = "myname"
  petname = false
}

output "frigga_names" {
  value = [
    module.null.name,
    module.frigga.name,
    module.myname.name
  ]
}
