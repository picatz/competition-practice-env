
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

resource "null_resource" "check_npm_installed" {
  provisioner "local-exec" {
    command = "command -v npm"
  }

  depends_on = [data.local_file.frontend_app_source, data.local_file.backend_app_source]
}


output "scoring_engine_md5" {
  value = md5("${data.local_file.frontend_app_source.content}${data.local_file.backend_app_source.content}")
}

resource "null_resource" "build_svelte_app_with_npm" {
  provisioner "local-exec" {
    working_dir = "app"
    command = "npm run build"
  }

  depends_on = [null_resource.check_npm_installed]
}

resource "null_resource" "build_go_app_with_packr" {
  provisioner "local-exec" {
    working_dir = "app"
    command = "GOOS=linux GOARCH=amd64 packr build -o scoring-engine ."
  }

  depends_on = [null_resource.check_packr_installed, null_resource.build_svelte_app_with_npm]
}

resource "null_resource" "template" {
  provisioner "local-exec" {
    working_dir = "template"
    command = "bash build.sh ${var.project}"
  }

  depends_on = [null_resource.build_go_app_with_packr]
}