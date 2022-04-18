data "cloudinit_config" "boot" {
  base64_encode = true
  gzip          = false

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOT
    #!/bin/bash
    sudo yum update -y
    yum install -y amazon-cloudwatch-agent
    EOT
  }

  part {
    content_type = "text/x-shellscript"
    content      = ""
  }
}

locals {
  base64_encoded = data.cloudinit_config.boot.rendered
}

output "base64_decoded" {
  value = base64decode(local.base64_encoded)
}

