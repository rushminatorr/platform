output "controller_ip" {
  depends_on  = ["null_resource.iofog"]
  description = "Controller ip"
  value       = "${file("controller_ip.txt")}"
}