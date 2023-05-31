provider "aws" {
  region                 = "ap-southeast-2"
  skip_region_validation = true
  default_tags {
    tags = {
      Purpose   = "Foundry VTT"
      ManagedBy = "Terraform"
      Owner     = "JDuncombe"
    }
  }
}

locals {
  vpc_name         = "Default"
  bucket_name      = "jduncombe-foundry-things"
  hosted_zone_name = "foundry.jduncombe.com"
}

module "foundry" {
  source           = "./modules/foundry"
  vpc_name         = local.vpc_name
  bucket_name      = local.bucket_name
  hosted_zone_name = local.hosted_zone_name
}
