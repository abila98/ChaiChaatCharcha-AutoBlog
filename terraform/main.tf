provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc1"
  }
}



resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.vpc1.id
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  cidr_block = var.public_subnet_1_cidr

  tags = {
    Name = "public_subnet_1"
  }
}


resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc1.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "rt-association-public" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public-rt.id
}


resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.vpc1.id
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  cidr_block = var.public_subnet_2_cidr

  tags = {
    Name = "public_subnet_2"
  }
}



resource "aws_route_table_association" "rt-association-public2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public-rt.id
}














resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.vpc1.id
  availability_zone       = "us-east-1a"
  cidr_block = var.private_subnet_1_cidr

  tags = {
    Name = "private_subnet_1"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "rt-association-private" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private-rt.id
}


resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.vpc1.id
  availability_zone       = "us-east-1b"
  cidr_block = var.private_subnet_2_cidr

  tags = {
    Name = "private_subnet_2"
  }
}

resource "aws_route_table_association" "rt-association-private2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private-rt.id
}



resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "igw"
  }
}


resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "ngw"
  }


  depends_on = [aws_internet_gateway.igw]
}