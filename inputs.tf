variable "account_id" {
  type        = string
  description = "The AWS account ID to share the subnets to."

  validation {
    condition     = can(regex("^\\d{12}$", var.account_id))
    error_message = "The account ID must be a 12-digit number."
  }
}

variable "account_name" {
  type        = string
  description = "The name of the AWS account to share the subnets to."
}


variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to share the subnets from."
}

variable "campus_subnets" {
  description = "A list of campus subnets to create and share. A campus subnet is a private subnet that uses a NAT Gateway to access the internet and has direct connectivity back to campus."
  type = list(object({
    region         = optional(string)
    zone           = optional(string)
    cidr           = string
    route_table_id = optional(string)
    name           = optional(string)
  }))
  default = []
  validation {
    condition = alltrue([
      for s in var.campus_subnets : can(cidrnetmask(s.cidr))
    ])
    error_message = "One or more subnet is missing a CIDR block."
  }
}

variable "public_subnets" {
  description = "A list of public subnets to create and share. A public subnet is one that has a direct route to the Internet Gateway but cannot access private networks in other regions or sites."
  type = list(object({
    region         = optional(string)
    zone           = optional(string)
    cidr           = string
    route_table_id = optional(string)
    name           = optional(string)
  }))
  default = []
  validation {
    condition = alltrue([
      for s in var.public_subnets : can(cidrnetmask(s.cidr))
    ])
    error_message = "One or more subnet is missing a CIDR block."
  }
}

variable "dmz_subnets" {
  description = "A list of DMZ subnets to create and share. A DZM subnet is one that has a direct route to the Internet Gateway and can access private networks in other regions or sites through a firewall."
  type = list(object({
    region         = optional(string)
    zone           = optional(string)
    cidr           = string
    route_table_id = optional(string)
  }))
  default = []
  validation {
    condition = alltrue([
      for s in var.dmz_subnets : can(cidrnetmask(s.cidr))
    ])
    error_message = "One or more subnet is missing a CIDR block."
  }
}

variable "private_subnets" {
  description = "A list of private subnets to create and share."
  type = list(object({
    region         = optional(string)
    zone           = optional(string)
    cidr           = string
    route_table_id = optional(string)
    name           = optional(string)
  }))
  default = []
  validation {
    condition = alltrue([
      for s in var.private_subnets : can(cidrnetmask(s.cidr))
    ])
    error_message = "One or more subnet is missing a CIDR block."
  }
}
