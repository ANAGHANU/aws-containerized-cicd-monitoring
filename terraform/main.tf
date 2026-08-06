####################################################
# VPC
####################################################

resource "aws_vpc" "main" {

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "devops-vpc"
  }
}

####################################################
# Public Subnet
####################################################

resource "aws_subnet" "public" {

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "ap-south-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

####################################################
# Internet Gateway
####################################################

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "devops-igw"
  }
}

####################################################
# Route Table
####################################################

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

####################################################
# Route Table Association
####################################################

resource "aws_route_table_association" "public" {

  subnet_id = aws_subnet.public.id

  route_table_id = aws_route_table.public.id
}

####################################################
# Security Group
####################################################

resource "aws_security_group" "web" {

  name = "devops-sg"

  description = "Security Group for DevOps Project"

  vpc_id = aws_vpc.main.id

  ##################################
  # SSH
  ##################################

  ingress {

    description = "SSH"

    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = [
      var.my_ip
    ]
  }

  ##################################
  # Flask
  ##################################

  ingress {

    description = "Flask"

    from_port = 5000

    to_port = 5000

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ##################################
  # Grafana
  ##################################

  ingress {

    description = "Grafana"

    from_port = 3000

    to_port = 3000

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ##################################
  # Prometheus
  ##################################

  ingress {

    description = "Prometheus"

    from_port = 9090

    to_port = 9090

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ##################################
  # Node Exporter
  ##################################

  ingress {

    description = "Node Exporter"

    from_port = 9100

    to_port = 9100

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ##################################
  # cAdvisor
  ##################################

  ingress {

    description = "cAdvisor"

    from_port = 8080

    to_port = 8080

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ##################################
  # Outbound
  ##################################

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "devops-sg"
  }
}

####################################################
# Latest Ubuntu AMI
####################################################

data "aws_ami" "ubuntu" {

  most_recent = true

  owners = [
    "099720109477"
  ]

  filter {

    name = "name"

    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }

  filter {

    name = "virtualization-type"

    values = [
      "hvm"
    ]
  }
}

####################################################
# IAM Role
####################################################

resource "aws_iam_role" "ec2_role" {

  name = "task-manager-ec2-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "task-manager-ec2-role"
  }
}

####################################################
# Attach AWS Managed ECR Policy
####################################################

resource "aws_iam_role_policy_attachment" "ecr_readonly" {

  role = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

####################################################
# EC2 Instance Profile
####################################################

resource "aws_iam_instance_profile" "ec2_profile" {

  name = "task-manager-instance-profile"

  role = aws_iam_role.ec2_role.name
}

####################################################
# EC2 Instance
####################################################

resource "aws_instance" "app" {

  ami = data.aws_ami.ubuntu.id

  instance_type = var.instance_type

  subnet_id = aws_subnet.public.id

  key_name = var.key_name

  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  root_block_device {

    volume_size = 20

    volume_type = "gp3"
  }

  tags = {
    Name = "task-manager-server"
  }
}

####################################################
# Amazon ECR
####################################################

resource "aws_ecr_repository" "task_manager" {

  name = "task-manager"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {

    scan_on_push = true
  }

  tags = {
    Name = "task-manager"
  }
}