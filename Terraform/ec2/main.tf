provider "aws" {
  region = "ap-southeast-1"
  profile = "default"
}

data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

#  filter {
#    name   = "architecture"
#    values = ["amd64"]
#  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_key_pair" "ariefjr-key" {
  key_name   = "ariefjr-terraform-key"
  public_key = "${file(var.my_public_key)}"
}

data "template_file" "init" {
  template = "${file("${path.module}/userdata.tpl")}"
}

resource "aws_instance" "ariefjr-instance" {
#  count                  = 2
  count                  = 1
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${aws_key_pair.ariefjr-key.id}"
  vpc_security_group_ids = ["${var.security_group}"]
  subnet_id              = "${element(var.subnets, count.index )}"
  user_data              = "${data.template_file.init.rendered}"

  tags = {
    Name = "ariefjr-instance-${count.index + 1}"
  }
}

resource "aws_ebs_volume" "ariefjr-ebs" {
#  count             = 2
  count             = 1
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  size              = 1
  type              = "gp2"
}

resource "aws_volume_attachment" "ariefjr-vol-attach" {
#  count        = 2
  count        = 1
  device_name  = "/dev/xvdh"
  instance_id  = "${aws_instance.ariefjr-instance.*.id[count.index]}"
  volume_id    = "${aws_ebs_volume.ariefjr-ebs.*.id[count.index]}"
  force_detach = true
}
