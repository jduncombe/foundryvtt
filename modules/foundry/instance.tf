# ec2 instance with launch template and asg
resource "aws_instance" "foundry" {

  launch_template {
    id      = aws_launch_template.foundry.id
    version = aws_launch_template.foundry.latest_version
  }

  tags = {
    Name = "FoundryVTT"
  }

}

resource "aws_security_group" "foundry" {
  name        = "foundry"
  description = "HTTP(S) ingress"
  vpc_id      = data.aws_vpc.managed_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_iam_instance_profile" "foundry" {
  name = "foundry_profile"
  role = aws_iam_role.foundry.name
}

data "aws_iam_policy_document" "foundry" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "foundry" {
  name               = "foundry_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.foundry.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

resource "aws_launch_template" "foundry" {
  name          = "foundry"
  instance_type = "t4g.small"

  image_id = data.aws_ami.al2023.id
  iam_instance_profile {
    name = aws_iam_instance_profile.foundry.name
  }
  ebs_optimized = true

  key_name = "foundry"
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.foundry.id]
    subnet_id                   = data.aws_subnets.public.ids[0]
  }

  user_data = base64encode(templatefile("${path.module}/data/foundry.tfpl", { bucket_name = var.bucket_name, domain_name = var.hosted_zone_name }))
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.foundry_zone.zone_id
  name    = var.hosted_zone_name
  type    = "A"
  ttl     = 300
  records = [aws_instance.foundry.public_ip]
}
