provider "aws" {
  region = var.cluster.region
  profile = var.cluster.profile
}

# Initialize availability zone data from AWS
data "aws_availability_zones" "available" {
    # List of availability zones that do not support eks
    exclude_names = ["us-east-1e"]
}


resource "aws_security_group" "ssh_all" {
  name_prefix = "ssh_all"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

# Vpc resource
resource "aws_vpc" "vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    ClusterName = var.cluster.name
    Name = "mks-vpc"
    mks = "true"
  }
}

# Internet gateway for the public subnets
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    ClusterName = var.cluster.name
    Name = "mks-internet-gateway"
    mks = "true"
  }
}

# Subnet (public)
resource "aws_subnet" "public_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.20.${10+count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    ClusterName = var.cluster.name
    Name = "mks-public-subnet"
    mks = "true"
  }
}

# Subnet (private)
resource "aws_subnet" "private_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.20.${20+count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    ClusterName = var.cluster.name
    Name = "mks-private-subnet"
    mks = "true"
  }
}

# Routing table for public subnets
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    ClusterName = var.cluster.name
    Name = "mks-public-route-table"
    mks = "true"
  }
}

resource "aws_route_table_association" "route" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.route_table_public.id
}

# Elastic IP for NAT gateway
resource "aws_eip" "nat" {
  vpc = true
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.private_subnet.*.id, 1)
  depends_on    = [aws_internet_gateway.internet_gateway]
}

# Routing table for private subnets
resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    ClusterName = var.cluster.name
    Name = "mks-private-route-table"
    mks = "true"
  }
}

resource "aws_route_table_association" "private_route" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.route_table_private.id
}

