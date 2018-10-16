output "ip" {
  value = "${aws_instance.zk.*.public_ip}"
}