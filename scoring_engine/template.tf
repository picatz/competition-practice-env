resource "null_resource" "template" {
  provisioner "local-exec" {
    working_dir = "template"
    command = "bash build.sh ${var.project}"
  }
}