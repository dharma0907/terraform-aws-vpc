resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge(var.vpc_tags, local.common_tags)
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.igw_tags,local.common_tags)
}

# we are creating two subents one in us-eat1a nd 1b
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet)  
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet[count.index] #us-east-1a

  availability_zone = local.az_names[count.index] #us-east-1a
  map_public_ip_on_launch = true


  tags = merge(var.public_subnet_tags, local.common_tags, 
  {
  Name = "${local.common_name}-${split("-", local.az_names[count.index])[2]}" #roboshop-dev-1a,roboshop-dev-1b
  # split function is used for dividing the value by , : - for string
  }
  )
}


# creating private subnet
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet)  
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet[count.index] #us-east-1a
  availability_zone = local.az_names[count.index] #us-east-1a
  map_public_ip_on_launch = false


  tags = merge(var.private_subnet_tags, local.common_tags, 
  {
  Name = "${local.common_name}-${split("-", local.az_names[count.index])[2]}" #roboshop-dev-1a,roboshop-dev-1b
  # split function is used for dividing the value by , : - for string
  }
  )
}


resource "aws_subnet" "database_subnet" {
  count = length(var.database_subnet)  
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet[count.index] #us-east-1a
  availability_zone = local.az_names[count.index] #us-east-1a
  map_public_ip_on_launch = true


  tags = merge(var.database_subnet_tags, local.common_tags, 
  {
  Name = "${local.common_name}-${split("-", local.az_names[count.index])[2]}" #roboshop-dev-1a,roboshop-dev-1b
  # split function is used for dividing the value by , : - for string
  }
  )
}

####TILL NOW WE CRRATED VPC, 3 SUBNETS PRIVATE PUBLIC AND DATABASE############


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id


  tags = merge(
      var.private_route_table_tags,
      local.common_tags,
      {
        Name = "${local.common_name}-public"
      }

  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id


  tags = merge(
      var.private_route_table_tags,
      local.common_tags,
      {
        Name = "${local.common_name}-public"
      }

  )
}


resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id


  tags = merge(
      var.private_route_table_tags,
      local.common_tags,
      {
        Name = "${local.common_name}-public"
      }

  )
}

###########ROUTE TABLE ASSOCIATION################
resource "aws_route_table_association" "public" {
   count = length(var.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private" {
  count = length(var.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
   count = length(var.database_subnet)
  subnet_id      = aws_subnet.database_subnet[count.index].id
  route_table_id = aws_route_table.database.id
}

resource "aws_eip" "nat" {
  domain   = "vpc"

  tags = merge(
     var.eip_tags,
     local.common_tags,
     {
        Name = "${local.common_name}-nat"
     }

  )
}


resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = merge(
    var.nat_tags,
    local.common_tags
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

#####ATTACHING ROUTE######################
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  #vpc_peering_connection_id = "pcx-45ff3dc1"
  gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  #vpc_peering_connection_id = "pcx-45ff3dc1"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  #vpc_peering_connection_id = "pcx-45ff3dc1"
  nat_gateway_id = aws_nat_gateway.main.id
}

