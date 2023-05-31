terraform {
  backend "s3" {
    region                 = "ap-southeast-4"
    skip_region_validation = true
  }
}
