# ----------------------------
# Create VPC
# ----------------------------

resource "aws_vpc" "custom_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "custom_public_vpc"
  }

}

# ----------------------------
# Fetch availability zones for the region
# ----------------------------

data "aws_availability_zones" "available" {
  state = "available"

}

# ----------------------------
# Create subnets
# ----------------------------

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# ----------------------------
# Create IGW
# ----------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "custom-vpc-igw"
  }
}

# ----------------------------
# Create public route table
# ----------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "public-route-table"
  }

}

# ----------------------------
# Add default route
# ----------------------------

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# ----------------------------
# Add route table association
# ----------------------------

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

}