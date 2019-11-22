
data "local_file" "backend_app_source" {
  filename = "app/front-end/index.html"
}

data "local_file" "frontend_app_source" {
  filename = "app/main.go"
}

resource "null_resource" "check_packr_installed" {
  provisioner "local-exec" {
    command = "command -v packr"
  }

  depends_on = [data.local_file.frontend_app_source, data.local_file.backend_app_source]
}

resource "null_resource" "build_go_app_with_packr" {
  provisioner "local-exec" {
    working_dir = "app"
    command = "GOOS=linux GOARCH=amd64 packr build -o scoring-engine ."
  }

  depends_on = [null_resource.check_packr_installed]
}

resource "null_resource" "template" {
  provisioner "local-exec" {
    working_dir = "template"
    command = "bash build.sh ${var.project}"
  }

  depends_on = [null_resource.build_go_app_with_packr]
}