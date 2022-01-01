locals {
  azs = ["ap-northeast-2a", "ap-northeasst-2b", "ap-northeast-2c"]
}

resource "random_integer" "az" {
  min = 0
  max = length(local.azs) - 1
}

resource "local_file" "cli-json" {
  content = templatefile(join("/", [path.module, "templates", "cli-scaffold.tpl"]), {
    az        = local.azs[random_integer.az.result]
    vpc       = "your_vpc_id"
    nodegroup = "nodegroup_arn"
    role      = "role_arn"
    emr_name  = "emr11"
    eks_name  = "eks11"
    alarm = jsonencode([
      {
        source = "aws:cloudwatch:alarm"
        value  = "alarm1_arn"
      },
      {
        source = "aws:cloudwatch:alarm"
        value  = "alarm2_arn"
    }])
  })
  filename        = format("%s/generated/request.json", path.module)
  file_permission = "0600"
}

resource "null_resource" "render-json" {
  depends_on = [local_file.cli-json, ]
  provisioner "local-exec" {
    when    = create
    command = "cat ${path.module}/generated/request.json"
  }
}

resource "null_resource" "rm-dir" {
  depends_on = [local_file.cli-json, null_resource.render-json]
  provisioner "local-exec" {
    when    = destroy
    command = "rm -r ${path.module}/generated/"
  }
}
