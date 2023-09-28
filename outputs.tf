output "private_subnets" {
  value = {
    for s in aws_subnet.private_subnet : s.tags.Name => s.id
  }
}

output "public_subnets" {
  value = {
    for s in aws_subnet.public_subnet : s.tags.Name => s.id
  }
}

output "campus_subnets" {
  value = {
    for s in aws_subnet.campus_subnet : s.tags.Name => s.id
  }
}
