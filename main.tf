provider "aws" {
  region = var.region
}


resource "tls_private_key" instance {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" instance {
  key_name   = var.myname
  public_key = tls_private_key.instance.public_key_openssh
}

resource "aws_security_group" "instance" {
  name        = var.myname
  description = "Allow SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.mycidr
  }

  ingress {
    description = "PING"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = var.mycidr
  }

  egress {
    description = "Allow ALL"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.myname
  }
}

resource "aws_autoscaling_group" "my" {
  name                = "tf-asg-eip_pool"
  min_size            = 1
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = data.aws_subnet_ids.default.ids
  launch_template {
    id      = aws_launch_template.foo.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "foo" {
  name                                 = var.myname
  image_id                             = data.aws_ami.latest_centos_7.id
  instance_type                        = "t2.micro"
  instance_initiated_shutdown_behavior = "terminate"
  key_name                             = aws_key_pair.instance.key_name
  #user_data = filebase64("${path.module}/userdata.sh")

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.instance.id]
    delete_on_termination       = true
  }

  #block_device_mappings {
  #  ebs {
  #    delete_on_termination = true
  #  }
  #}

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.myname
    }
  }

}

resource "aws_eip" "eip" {
  count = 4
  vpc   = true
  tags = {
    Name                 = var.myname
    AutoScalingGroupName = aws_autoscaling_group.my.name
  }
}

