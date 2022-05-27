
locals {
  mandatory_tag = {
    line_of_business        = "hospital"
    ado                     = "max"
    tier                    = "WEB"
    operational_environment = upper(terraform.workspace)
    tech_poc_primary        = "udu.udu25@gmail.com"
    tech_poc_secondary      = "udu.udu25@gmail.com"
    application             = "http"
    builder                 = "udu.udu25@gmail.com"
    application_owner       = "kojitechs.com"
    vpc                     = "WEB"
    cell_name               = "WEB"
    component_name          = "kojitechs"
  }
  vpc_id = aws_vpc.kojitechs_vpc.id

}

# creating a vpc

resource "aws_vpc" "kojitechs_vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "kojitechs_vpc"
  }
}

# creating IGW

resource "aws_internet_gateway" "igw" {
  vpc_id = local.vpc_id

  tags = {
    Name = "kojitechs"
  }
}

 # aws_vpc.kojitechs_vpc.id

 # creating public subnet

 data "aws_availability_zones" "azs" {
    state = "available"
 }

resource "aws_subnet" "pub_subnet_1" {
  vpc_id     = local.vpc_id
  cidr_block = var.pub_subnet_cidr[0]
  availability_zone = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "pub_subnet_1"
  }
}

resource "aws_subnet" "pub_subnet_2" {
  vpc_id     = local.vpc_id
  cidr_block = var.pub_subnet_cidr[1]
  availability_zone = data.aws_availability_zones.azs.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "pub_subnet_2"
  }
}

resource "aws_subnet" "priv_subnet_1" {
  vpc_id     = local.vpc_id
  cidr_block = var.priv_subnet_cidr[0]
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
    Name = "priv_subnet_${data.aws_availability_zones.azs.names[0]}" # RESULT priv_subnet_us-east-1a
  }
}

resource "aws_subnet" "priv_subnet_2" {
  vpc_id     = local.vpc_id
  cidr_block = var.priv_subnet_cidr[1]
  availability_zone = data.aws_availability_zones.azs.names[1]

  tags = {
    Name = "priv_subnet_${data.aws_availability_zones.azs.names[1]}"
  }
}

resource "aws_subnet" "database_subnet_1" {
  vpc_id     = local.vpc_id
  cidr_block = var.database_subnet_cidr[0]
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
    Name = "database_subnet_${data.aws_availability_zones.azs.names[0]}"
  }
}

resource "aws_subnet" "database_subnet_2" {
  vpc_id     = local.vpc_id
  cidr_block = var.database_subnet_cidr[1]
  availability_zone = data.aws_availability_zones.azs.names[1]

  tags = {
    Name = "database_subnet_${data.aws_availability_zones.azs.names[1]}"
  }
}

# Creating public route table

resource "aws_route_table" "route_table" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id # destination
  }

  tags = {
    Name = "kojitechs_route_table"
  }
}

# creating route table association

resource "aws_route_table_association" "pub_subnet_1" {
  subnet_id      = aws_subnet.pub_subnet_1.id
  route_table_id = aws_route_table.route_table.id
}
resource "aws_route_table_association" "pub_subnet_2" {
  subnet_id     = aws_subnet.pub_subnet_2.id
  route_table_id = aws_route_table.route_table.id
}


# working with default route table

resource "aws_default_route_table" "default_routetable" {
  default_route_table_id = aws_vpc.kojitechs_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "default_routetable"
  }
}

# creating NAT Gateway

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.priv_subnet_1.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

#creating EIP since NAT Gateway can be reusable

resource "aws_eip" "eip" {
  vpc      = true
  depends_on = [aws_internet_gateway.igw]
}