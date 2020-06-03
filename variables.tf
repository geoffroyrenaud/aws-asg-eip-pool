variable region {
  type    = string
  default = "eu-west-1"
}

variable myname {
  type    = string
  default = "demo-asg-eip"
}

variable mycidr {
  type    = list
  default = ["0.0.0.0/0"]
}
