variable "cidr_block_private" {
  description = "cidr blocks for private subnets"
}

variable "cidr_block_public" {
  description = "cidr blocks for public subnets"
}

variable "cidr_block_database_private" {
  description = "cidr blocks for database subnets"
}

variable "availability_zones" {
  description = "availability zones"
}

variable "aws_region" {
  description = "aws region"
}

