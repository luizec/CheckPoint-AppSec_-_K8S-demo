terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.35.0"
    }
  }
}

provider "aws" {
  region = var.region
  access_key = var.access-key
  secret_key = var.secret-key
}

resource "aws_vpc" "my-vpc" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "vpc-eks-appsec"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "igw-eks-appsec"
  }
  depends_on = [ aws_vpc.my-vpc ]
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  depends_on = [ aws_internet_gateway.gw ] 
}

resource "aws_security_group" "nsg-allow-all" {
  name        = "nsg-eks-appsec"
  description = "Allow inbound/outbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nsg-eks-appsec"
  }
  depends_on = [aws_vpc.my-vpc]
}

resource "aws_subnet" "my-subnet-1" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "net-eks-appsec-1"
  }
  depends_on = [ aws_vpc.my-vpc ]
}

resource "aws_subnet" "my-subnet-2" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "net-eks-appsec-2"
  }
  depends_on = [ aws_vpc.my-vpc ]
}
resource "aws_subnet" "my-subnet-3" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.region}c"
  map_public_ip_on_launch = true

  tags = {
    Name = "net-eks-appsec-3"
  }
  depends_on = [ aws_vpc.my-vpc ]
}

resource "aws_route_table_association" "rtassociate1" {
  subnet_id      = aws_subnet.my-subnet-1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rtassociate2" {
  subnet_id      = aws_subnet.my-subnet-2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rtassociate3" {
  subnet_id      = aws_subnet.my-subnet-3.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_eks_cluster" "my-ekscluster" {
  name     = "eks-appsec"
  role_arn = "arn:aws:iam::134091980424:role/eksStudyClusterRole"
  
  vpc_config {
    subnet_ids = [aws_subnet.my-subnet-1.id, aws_subnet.my-subnet-2.id, aws_subnet.my-subnet-3.id]
  }
  depends_on = [aws_subnet.my-subnet-1, aws_subnet.my-subnet-2, aws_subnet.my-subnet-3]
}

resource "aws_eks_node_group" "my-nodegroup" {
  cluster_name    = aws_eks_cluster.my-ekscluster.name
  node_group_name = "eks-ng-eks-appsec"
  node_role_arn   = "arn:aws:iam::134091980424:role/EKSWorkerRole"
  subnet_ids      = [aws_subnet.my-subnet-1.id, aws_subnet.my-subnet-2.id, aws_subnet.my-subnet-3.id]
  instance_types  = ["t3.small"]
  ##instance_types  = ["t3.xlarge"]
  disk_size       = 10
  ##version = "1.20"

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 2
  }
  depends_on = [ aws_eks_cluster.my-ekscluster ]
}

resource "aws_eks_addon" "aws-ebs-csi-driver_addon" {
  cluster_name = aws_eks_cluster.my-ekscluster.name
  addon_name   = "aws-ebs-csi-driver"
  depends_on = [aws_eks_node_group.my-nodegroup]
}
