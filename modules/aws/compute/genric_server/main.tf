variable "env"               { }
variable "name"              { default = "ec2" }
variable "vpc_id"            { }
variable "ami"               { }
variable "key_name"          { }
variable "instance_type"     { }
variable "security_groups"   { type = "list" }
variable "subnet_ids"        { type = "list" }
variable "subdomain"         { }

variable "count"             { default = 1 }
variable "iam_instance_profile"   { }

variable "depends_id"        { default = ""}
variable "volume_size"       { default = "16" }
variable "volume_type"       { default = "gp2" }
variable "volume_encryption" { default = true }

variable "delete_on_termination" { default = true }

variable "disable_api_termination" { default = true }

variable "aws_region"        { default = "us-east-1" }
variable "backup" { default = "disable" }

variable "ebs_optimized" {
  default = ""
}

resource "aws_instance" "ec2" {
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  iam_instance_profile   = "${var.iam_instance_profile}"
  subnet_id              = "${element(var.subnet_ids, count.index)}"
  vpc_security_group_ids = ["${var.security_groups}"]
  key_name               = "${var.key_name}"
  count                  = "${var.count}"
  disable_api_termination = "${var.disable_api_termination}"
  ebs_optimized ="${var.ebs_optimized}"
  tags {
    Name = "${var.name}-${count.index + 1}.${var.subdomain}"
    enviroment = "${var.env}"
    terraform = "true"
    Monitor = "Enable"
  }
  volume_tags {
    backup = "${var.backup}"
  }
  root_block_device {
    volume_size = "${var.volume_size}"
    volume_type = "${var.volume_type}"
    delete_on_termination = "${var.delete_on_termination}"
  }
}

output "private_ip"        { value = "${aws_instance.ec2.*.private_ip}" }
output "public_ip"         { value = "${aws_instance.ec2.*.public_ip}" }
output "instance_id"       { value = ["${aws_instance.ec2.*.id}"] }
output "subnet_id"         { value = "${aws_instance.ec2.*.subnet_id}" }
output "security_group_id" { value = "${flatten(aws_instance.ec2.*.vpc_security_group_ids)}" }
output "az"                { value = "${aws_instance.ec2.*.availability_zone}" }
