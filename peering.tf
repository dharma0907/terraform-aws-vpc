resource "aws_vpc_peering_connection" "default_vpc" {
  count = var.is_peering_required ? 1 : 0
  #peer_owner_id = var.peer_owner
    peer_vpc_id   = data.aws_vpc.default.id#acceptor--in our case default vpc
  # get acceptor from data source because it's avaialble in AWS
  auto_accept = true
  vpc_id        = aws_vpc.main.id #roboshop, this is requester
  

    accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = merge(
    var.vpc_peering_tags,
    local.common_tags,
    {
        Name = "${local.common_name}-default"
    }
  )
}
resource "aws_route" "public_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default_vpc[count.index].id
}


resource "aws_route" "private_peering" {
    count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  #vpc_peering_connection_id = "pcx-45ff3dc1"
  vpc_peering_connection_id = aws_vpc_peering_connection.default_vpc[count.index].id
}

resource "aws_route" "database_peering" {
    count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  #vpc_peering_connection_id = "pcx-45ff3dc1"
 vpc_peering_connection_id = aws_vpc_peering_connection.default_vpc[count.index].id
}

resource "aws_route" "default" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_route_table.default_vpc_route_table.id #defined in data.tf
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.default_vpc[count.index].id #thsis gives vpc peering connection id
}

