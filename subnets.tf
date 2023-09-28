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

# Pre-determine the availability zones to use for the public subnets
locals {
  public_subnets = [for i, s in var.public_subnets :
    {
      cidr = s.cidr
      name = s.name != null ? s.name : "public-${i + 1}"
      zone = s.zone != null ? s.zone : (
        s.region != null ? local.default_availability_zones[s.region][i % 2] : local.default_availability_zones[local.default_region][i % 2]
      )
      region         = s.region
      route_table_id = s.route_table_id != null ? s.route_table_id : data.aws_route_table.rtb_public.id
    }
  ]
}

data "aws_route_table" "rtb_public" {
  filter {
    name   = "tag:Name"
    values = ["rtb-vpc1-public-subnets"]
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(local.public_subnets)

  vpc_id                  = var.vpc_id
  availability_zone       = local.public_subnets[count.index].zone
  cidr_block              = local.public_subnets[count.index].cidr
  map_public_ip_on_launch = true
  # provider          = aws.us-east-1
  tags = {
    Name = "subnet-${var.account_name}-${local.public_subnets[count.index].zone}-${local.public_subnets[count.index].name}"
  }
}

resource "aws_route_table_association" "rtb_public_subnet" {
  count = length(local.public_subnets)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = local.public_subnets[count.index].route_table_id
  # provider       = aws.us-east-1
}


resource "aws_ram_resource_association" "share_public_subnet" {
  count = length(local.public_subnets)

  resource_arn       = aws_subnet.public_subnet[count.index].arn
  resource_share_arn = aws_ram_resource_share.share_to_account.arn
  #   provider           = aws.us-east-1
}



################################################################################
#
#   DMZ Subnets
#
################################################################################

# Pre-determine the availability zones to use for the public subnets
locals {
  dmz_subnets = [for i, s in var.dmz_subnets :
    {
      cidr = s.cidr
      zone = s.zone != null ? s.zone : (
        s.region != null ? local.default_availability_zones[s.region][i % 2] : local.default_availability_zones[local.default_region][i % 2]
      )
      region         = s.region
      route_table_id = s.route_table_id != null ? s.route_table_id : data.aws_route_table.rtb_dmz.id
    }
  ]
}


data "aws_route_table" "rtb_dmz" {
  filter {
    name   = "tag:Name"
    values = ["rtb-vpc1-dmz-subnets"]
  }
}

resource "aws_subnet" "dmz_subnet" {
  count = length(local.dmz_subnets)

  vpc_id                  = var.vpc_id
  availability_zone       = local.dmz_subnets[count.index].zone
  cidr_block              = local.dmz_subnets[count.index].cidr
  map_public_ip_on_launch = true
  # provider          = aws.us-east-1
  tags = {
    Name = "subnet-${var.account_name}-${local.dmz_subnets[count.index].zone}-dmz-${count.index + 1}"
  }
}

resource "aws_route_table_association" "rtb_dmz_subnet" {
  count = length(local.dmz_subnets)

  subnet_id      = aws_subnet.dmz_subnet[count.index].id
  route_table_id = local.dmz_subnets[count.index].route_table_id
  # provider       = aws.us-east-1
}


resource "aws_ram_resource_association" "share_dmz_subnet" {
  count = length(local.dmz_subnets)

  resource_arn       = aws_subnet.dmz_subnet[count.index].arn
  resource_share_arn = aws_ram_resource_share.share_to_account.arn
  #   provider           = aws.us-east-1
}


################################################################################
#
#   Private Subnets
#
################################################################################

# Pre-determine the availability zones to use for the public subnets
locals {
  private_subnets = [for i, s in var.private_subnets :
    {
      cidr           = s.cidr
      zone           = s.zone
      region         = s.region
      name           = s.name != null ? s.name : "private-${i + 1}"
      route_table_id = s.route_table_id != null ? s.route_table_id : data.aws_route_table.rtb_private[s.zone].id
    }
  ]
}

data "aws_route_table" "rtb_private" {
  for_each = toset(local.default_availability_zones[local.default_region])

  filter {
    name   = "tag:Name"
    values = ["rtb-vpc1-private-subnets-${local.default_availability_zones[local.default_region][index(local.default_availability_zones[local.default_region], each.value)]}"]
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(local.private_subnets)

  vpc_id            = var.vpc_id
  availability_zone = local.private_subnets[count.index].zone
  cidr_block        = local.private_subnets[count.index].cidr
  tags = {
    Name = "subnet-${var.account_name}-${local.private_subnets[count.index].zone}-${local.private_subnets[count.index].name}"
  }
}

resource "aws_route_table_association" "rtb_private_subnet" {
  count = length(local.private_subnets)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = local.private_subnets[count.index].route_table_id
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

# Pre-determine the availability zones to use for the public subnets
locals {
  campus_subnets = [for i, s in var.campus_subnets :
    {
      cidr = s.cidr
      name = s.name != null ? s.name : "campus-${i + 1}"
      zone = s.zone != null ? s.zone : (
        s.region != null ? local.default_availability_zones[s.region][i % 2] : local.default_availability_zones[local.default_region][i % 2]
      )
      region         = s.region
      route_table_id = s.route_table_id != null ? s.route_table_id : data.aws_route_table.rtb_campus[s.zone].id
    }
  ]
}



data "aws_route_table" "rtb_campus" {
  for_each = toset(local.default_availability_zones[local.default_region])

  filter {
    name   = "tag:Name"
    values = ["rtb-vpc1-campus-subnets-${local.default_availability_zones[local.default_region][index(local.default_availability_zones[local.default_region], each.value)]}"]
  }
}

resource "aws_subnet" "campus_subnet" {
  count = length(local.campus_subnets)

  vpc_id            = var.vpc_id
  availability_zone = local.campus_subnets[count.index].zone
  cidr_block        = local.campus_subnets[count.index].cidr
  tags = {
    Name = "subnet-${var.account_name}-${local.campus_subnets[count.index].zone}-${local.campus_subnets[count.index].name}"
  }
}

resource "aws_route_table_association" "rtb_campus_subnet" {
  count = length(local.campus_subnets)

  subnet_id      = aws_subnet.campus_subnet[count.index].id
  route_table_id = local.campus_subnets[count.index].route_table_id
}

resource "aws_ram_resource_association" "share_campus_subnet" {
  count = length(local.campus_subnets)

  resource_arn       = aws_subnet.campus_subnet[count.index].arn
  resource_share_arn = aws_ram_resource_share.share_to_account.arn
}
