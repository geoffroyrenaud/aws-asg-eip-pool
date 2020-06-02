data aws_ami latest_centos_7 {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64*"]
  }

  filter {
    name   = "description"
    values = ["CentOS Linux 7 x86_64 HVM EBS ENA*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["679593333241"]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}
