output "yamldecode" {
  value = yamldecode(file("${path.module}/values.yaml"))
}
