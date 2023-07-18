provider "aws" {
  region     = var.aws_region[0]
  access_key = "AKIA3BWTZKZCMSIT25O5"
  secret_key = "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"
}

# 1. Create VPC

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "alap-vpc"
  }
}

# 2. Create Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "alap-igw"
  }
}
# 3. Create Elastic IP for NAT Gateway

resource "aws_eip" "elastic-ip" {
  vpc = true

  tags = {
    Name = "alap-eip"
  }
  depends_on = [aws_internet_gateway.igw]
}

# 4. Create NAT Gateway

resource "aws_nat_gateway" "NAT-Gateway" {
  allocation_id = aws_eip.elastic-ip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags = {
    Name = "alap-ngw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# 5. Create Route Tables

resource "aws_route_table" "route-table-public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "alap-public-route-table"
  }
}

resource "aws_route_table" "route-table-private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT-Gateway.id
  }

  tags = {
    Name = "alap-private-route-table"
  }
}

# 6. Create Subnets

# Private Subnets

resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.cidr_block_private)
  cidr_block        = var.cidr_block_private[count.index]
  availability_zone = "us-east-1${var.availability_zones[count.index]}"

  tags = {
    Name = "alap-private-subnet-${var.availability_zones[count.index]}"
  }
}

# Public Subnets

resource "aws_subnet" "public_subnets" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.cidr_block_public)
  cidr_block        = var.cidr_block_public[count.index]
  availability_zone = "us-east-1${var.availability_zones[count.index]}"

  tags = {
    Name = "alap-public-subnet-${var.availability_zones[count.index]}"
  }
}

# Database Private Subnets

resource "aws_subnet" "database_subnets" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.cidr_block_database_private)
  cidr_block        = var.cidr_block_database_private[count.index]
  availability_zone = "us-east-1${var.availability_zones[count.index]}"

  tags = {
    Name = "alap-database-subnet-${var.availability_zones[count.index]}"
  }
}

# 7. Associate subnets with route tables

# Associate private subnets to private route table
resource "aws_route_table_association" "private-association" {
  count          = length(var.cidr_block_private)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.route-table-private.id
}

# Associate database private subnets to private route table
resource "aws_route_table_association" "database-private-association" {
  count          = length(var.cidr_block_database_private)
  subnet_id      = aws_subnet.database_subnets[count.index].id
  route_table_id = aws_route_table.route-table-private.id
}

# Associate public subnets to public route table
resource "aws_route_table_association" "public-association" {
  count          = length(var.cidr_block_public)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.route-table-public.id
}
