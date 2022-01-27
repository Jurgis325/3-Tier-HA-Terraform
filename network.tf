#Create VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

#Create subnets
#Public Subnets
resource "aws_subnet" "Front-A" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Front-A"
  }
}

resource "aws_subnet" "Front-B" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.11.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Front-B"
  }
}

#Private Subnets
resource "aws_subnet" "Middle-A" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Middle-A"
  }
}

resource "aws_subnet" "Middle-B" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.12.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Middle-B"
  }
}

resource "aws_subnet" "Back-A" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Back-A"
  }
}

resource "aws_subnet" "Back-B" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.13.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Back-B"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
}

#Route table
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}
#Route table association for A group
resource "aws_route_table_association" "route_table_association_public" {
  subnet_id      = aws_subnet.Front-A.id
  route_table_id = aws_route_table.route_table_public.id
}

#Route table association for B group
resource "aws_route_table_association" "route_table_association_public" {
  subnet_id      = aws_subnet.Front-B.id
  route_table_id = aws_route_table.route_table_public.id
}

#elastic IP for Middle A
resource "aws_eip" "nat_eip-A" {
  vpc        = true
}

#elastic IP for Middle B
resource "aws_eip" "nat_eip-B" {
  vpc        = true
}

#NAT gateway for group A
resource "aws_nat_gateway" "nat_gateway-A" {
  allocation_id = aws_eip.nat_eip-A.id
  subnet_id     = aws_subnet.Front-A.id
}

#NAT gateway for group B
resource "aws_nat_gateway" "nat_gateway-B" {
  allocation_id = aws_eip.nat_eip-B.id
  subnet_id     = aws_subnet.Front-A.id
}

#route table for middle subnet A group
resource "aws_route_table" "route_table_middle-A" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway-A.id
  }
}

resource "aws_route_table_association" "route_table_association_private-A" {
  subnet_id      = aws_subnet.Middle-A.id
  route_table_id = aws_route_table.route_table_middle-A.id
}

#route table for middle subnet B group
resource "aws_route_table" "route_table_middle-B" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway-B.id
  }
}

resource "aws_route_table_association" "route_table_association_private-B" {
  subnet_id      = aws_subnet.Middle-B.id
  route_table_id = aws_route_table.route_table_middle-B.id
}