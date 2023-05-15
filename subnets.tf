# ####
# # Public subnets
# ####



# resource "aws_subnet" "public_subnet" {
#   count = var.public_subnets_count

#   vpc_id            = aws_vpc.us_east_1.id
#   availability_zone = local.availability_zones[count.index]
#   cidr_block        = var.public_subnets_cidr_blocks[count.index]
#   provider          = aws.us-east-1
#   tags = {
#     Name = "subnet-${var.account_name}-${local.availability_zones[count.index]}-public-${count.index}"
#   }
# }


# resource "aws_ram_resource_association" "share_public_subnet" {
#     count = var.public_subnets_count

#   resource_arn       = aws_subnet.public_subnet[count.index].arn
#   resource_share_arn = aws_ram_resource_share.share_to_account.arn
#   provider           = aws.us-east-1
# }


# ####
# # Private Subnets
# ####

# data "aws_route_table" "rtb_private" {
#   count = var.private_subnets_count

#   filter {
#     name   = "tag:Name"
#     values = ["rtb-vpc1-private-subnets-${local.availability_zones[count.index]}"]
#   }
# }

# resource "aws_subnet" "private_subnet" {
#   count = var.private_subnets_count

#   vpc_id            = aws_vpc.us_east_1.id
#   availability_zone = local.availability_zones[count.index]
#   cidr_block        = var.private_subnets_cidr_blocks[count.index]
#   provider          = aws.us-east-1
#   tags = {
#     Name = "subnet-${var.account_name}-${local.availability_zones[count.index]}-private-${count.index}"
#   }
# }

# resource "aws_route_table_association" "rtb_private_subnet" {
#   count = var.private_subnets_count

#   subnet_id      = aws_subnet.private_subnet[count.index].id
#   route_table_id = aws_route_table.rtb_private[count.index].id
#   provider       = aws.us-east-1
# }

# resource "aws_ram_resource_association" "share_private_subnet" {
#   count = var.private_subnets_count

#   resource_arn       = aws_subnet.private_subnet[count.index].arn
#   resource_share_arn = aws_ram_resource_share.share_to_account.arn
#   provider           = aws.us-east-1
# }



################################################################################
#
#   Public subnets
#
################################################################################


data "aws_route_table" "rtb_public" {
  filter {
    name   = "tag:Name"
    values = ["rtb-vpc1-public-subnets"]
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnets)

  vpc_id            = var.vpc_id
  availability_zone = (
    var.public_subnets[count.index].zone != null ? var.public_subnets[count.index].zone : (
        var.public_subnets[count.index].region != null ? local.default_availability_zones[var.public_subnets[count.index].region][count.index % 2] : local.default_availability_zones[local.default_region][count.index % 2]
    )
  )
  cidr_block        = var.public_subnets[count.index].cidr
  map_public_ip_on_launch = true
  # provider          = aws.us-east-1
  tags = {
    Name = "subnet-${var.account_name}-${local.availability_zones[count.index]}-public-${count.index+1}"
  }
}

resource "aws_route_table_association" "rtb_public_subnet" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = (
    var.public_subnets[count.index].route_table_id != null ? var.public_subnets[count.index].route_table_id : data.aws_route_table.rtb_public.id
  )
  # provider       = aws.us-east-1
}


resource "aws_ram_resource_association" "share_public_subnet" {
  count = length(var.public_subnets)

  resource_arn       = aws_subnet.public_subnet[count.index].arn
  resource_share_arn = aws_ram_resource_share.share_to_account.arn
#   provider           = aws.us-east-1
}



################################################################################
#
#   DMZ Subnets
#
################################################################################


data "aws_route_table" "rtb_dmz" {
  filter {
    name   = "tag:Name"
    values = ["rtb-vpc1-dmz-subnets"]
  }
}

resource "aws_subnet" "dmz_subnet" {
  count = length(var.dmz_subnets)

  vpc_id            = var.vpc_id
  availability_zone = local.availability_zones[count.index]
  cidr_block        = var.dmz_subnets[count.index].cidr
  map_public_ip_on_launch = true
  # provider          = aws.us-east-1
  tags = {
    Name = "subnet-${var.account_name}-${local.availability_zones[count.index]}-dmz-${count.index+1}"
  }
}

resource "aws_route_table_association" "rtb_dmz_subnet" {
  count = length(var.dmz_subnets)

  subnet_id      = aws_subnet.dmz_subnet[count.index].id
  route_table_id = data.aws_route_table.rtb_dmz.id
  # provider       = aws.us-east-1
}


resource "aws_ram_resource_association" "share_dmz_subnet" {
  count = length(var.dmz_subnets)

  resource_arn       = aws_subnet.dmz_subnet[count.index].arn
  resource_share_arn = aws_ram_resource_share.share_to_account.arn
#   provider           = aws.us-east-1
}


################################################################################
#
#   Private Subnets
#
################################################################################


data "aws_route_table" "rtb_private" {
  count = length(var.private_subnets)

  filter {
    name   = "tag:Name"
    values = ["rtb-vpc1-private-subnets-${local.availability_zones[count.index]}"]
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnets)

  vpc_id            = var.vpc_id
  availability_zone = local.availability_zones[count.index]
  cidr_block        = var.private_subnets[count.index].cidr
  tags = {
    Name = "subnet-${var.account_name}-${local.availability_zones[count.index]}-private-${count.index+1}"
  }
}

resource "aws_route_table_association" "rtb_private_subnet" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = data.aws_route_table.rtb_private[count.index].id
#   provider       = aws.us-east-1
}

resource "aws_ram_resource_association" "share_private_subnet" {
  count = length(var.private_subnets)

  resource_arn       = aws_subnet.private_subnet[count.index].arn
  resource_share_arn = aws_ram_resource_share.share_to_account.arn
#   provider           = aws.us-east-1
}

################################################################################
#
#   Campus Subnets
#
################################################################################

data "aws_route_table" "rtb_campus" {
  count = length(var.campus_subnets)

  filter {
    name   = "tag:Name"
    values = ["rtb-vpc1-campus-subnets-${local.availability_zones[count.index]}"]
  }
}

resource "aws_subnet" "campus_subnet" {
  count = length(var.campus_subnets)

  vpc_id            = var.vpc_id
  availability_zone = local.availability_zones[count.index]
  cidr_block        = var.campus_subnets[count.index].cidr
  tags = {
    Name = "subnet-${var.account_name}-${local.availability_zones[count.index]}-campus-${count.index+1}"
  }
}

resource "aws_route_table_association" "rtb_campus_subnet" {
  count = length(var.campus_subnets)

  subnet_id      = aws_subnet.campus_subnet[count.index].id
  route_table_id = data.aws_route_table.rtb_campus[count.index].id
}

resource "aws_ram_resource_association" "share_campus_subnet" {
  count = length(var.campus_subnets)

  resource_arn       = aws_subnet.campus_subnet[count.index].arn
  resource_share_arn = aws_ram_resource_share.share_to_account.arn
}
