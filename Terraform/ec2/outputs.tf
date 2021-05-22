output "instance_id" {
  value = "${element(aws_instance.ariefjr-instance.*.id, 1)}"
}

output "server_ip" {
  value = "${join(",",aws_instance.ariefjr-instance.*.private_ip)}"
}