data "template_file" "api-server-init" {
  template = "${file("templates/api-server-init.yaml")}"
}