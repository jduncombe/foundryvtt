# foundryvtt
A simple repository using terraform to configure a FoundryVTT server in AWS.

## Requirements:

 - Terraform 1.4.6+
 - AWS Provider 5.x
 - AWS Account and credentials
 - S3 Bucket for storing foundry zip
 - S3 Bucket for strong Terraform state
 - AWS Route53 HostedZone with configured delegation if not the apex zone.

## Instructions

1. Run `terraform init`
1. Configure state bucket
1. Run `terraform validate`
1. Run `terraform plan`
1. Review output and confirm assets
1. Run `terraform apply -auto-approve`
