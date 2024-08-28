terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region     = "ap-south-1"
  access_key = var.access_key
  secret_key = var.secret_key
}


# ========================== Creating the VPC ============================= #

resource "aws_vpc" "VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "tvpc"
  }
}


# ========================== Creating the Subnets ============================= #

resource "aws_subnet" "Pubsub" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "pubsub"
  }
}


resource "aws_subnet" "Prisub" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "prisub"
  }
}



#  ====================== Public Subnet ===================== #

resource "aws_internet_gateway" "tigw" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "tigw"
  }
}


resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tigw.id
  }

  tags = {
    Name = "pubrt"
  }
}

resource "aws_route_table_association" "pub_rt_a" {
  subnet_id      = aws_subnet.Pubsub.id
  route_table_id = aws_route_table.pub_rt.id
}


# ============================ Private Subnets ======================== #

resource "aws_eip" "eip" {
  domain   = "vpc"
}



#  ========================= Security Group ======================== #


#  ====== pub sg ======== #
resource "aws_security_group" "pub_allow_tls" {
  name        = "pub_allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.VPC.id

  tags = {
    Name = "pub_allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "pub_allow_tls_ipv4" {
  security_group_id = aws_security_group.pub_allow_tls.id
  cidr_ipv4         = aws_vpc.VPC.cidr_block
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"

}
resource "aws_vpc_security_group_ingress_rule" "pub_allow_http_ipv4" {
  security_group_id = aws_security_group.pub_allow_tls.id
  cidr_ipv4         = aws_vpc.VPC.cidr_block
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

}

resource "aws_vpc_security_group_egress_rule" "pub_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.pub_allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


#  ==== pirvate sg =======


resource "aws_security_group" "pri_allow_tls" {
  name        = "pri_allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.VPC.id

  tags = {
    Name = "pri_allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "pri_allow_tls_ipv4" {
  security_group_id = aws_security_group.pri_allow_tls.id
  cidr_ipv4         = aws_vpc.VPC.cidr_block
  ip_protocol       = "-1"
}


resource "aws_vpc_security_group_egress_rule" "pri_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.pri_allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


#  ==================== EC2 Instances ===================== #


resource "aws_instance" "pub_ec2" {
  ami           = "ami-0c2af51e265bd5e0e"
  instance_type = "t2.micro"
  subnet_id =  aws_subnet.Pubsub.id
  vpc_security_group_ids = [aws_security_group.pub_allow_tls.id ]
  key_name = "Rishi"
  associate_public_ip_address = true


  tags = {
    Name = "Pub_EC2"
  }
}



resource "aws_instance" "pri_ec2" {
  ami           = "ami-0c2af51e265bd5e0e"
  instance_type = "t2.micro"
  subnet_id =  aws_subnet.Prisub.id
  vpc_security_group_ids = [aws_security_group.pri_allow_tls.id ]
  key_name = "Rishi"
  associate_public_ip_address = true


  tags = {
    Name = "Pri_EC2"
  }
}
