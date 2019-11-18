resource "null_resource" "build_go_app" {
  provisioner "local-exec" {
    working_dir = "app"
    command = "GOOS=linux GOARCH=amd64 packr build -o scoring-engine ."
  }
}

resource "null_resource" "template" {
  provisioner "local-exec" {
    working_dir = "template"
    command = "bash build.sh ${var.project}"
  }

  depends_on = [null_resource.build_go_app]
}