#VPC
data "aws_vpc" "managed_vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}
#public subnets
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.managed_vpc.id]
  }
}

#route53 hosted zone
data "aws_route53_zone" "foundry_zone" {
  name         = var.hosted_zone_name
  private_zone = false
}


data "aws_ami" "al2023" {
  most_recent = true


  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["al2023-ami-2023*-arm64"]
  }
}
