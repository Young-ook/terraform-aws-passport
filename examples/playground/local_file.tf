resource "local_file" "cli-request-json" {
  content = templatefile(join("/", [path.module, "templates", "emrcli-scaffold.tpl"]), {
    emr_name = "emr11"
    eks_name = "eks11"
  })
  filename        = format("%s/generated/request.json", path.module)
  file_permission = "0600"
}

resource "null_resource" "render-json" {
  depends_on = [local_file.cli-request-json, ]
  provisioner "local-exec" {
    when    = create
    command = "cat ${path.module}/generated/request.json"
  }
}

resource "null_resource" "rm-dir" {
  depends_on = [local_file.cli-request-json, null_resource.render-json]
  provisioner "local-exec" {
    when    = destroy
    command = "rm -r ${path.module}/generated/"
  }
}
