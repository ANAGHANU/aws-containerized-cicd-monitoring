variable "aws_region" {
  default = "ap-south-2"
}

variable "availability_zone" {
  default = "ap-south-2a"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair"
}

variable "my_ip" {
  description = "Your public IP address in CIDR notation"
  type        = string
}