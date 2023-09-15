locals {
  use_existing_route53_zone = true

  domain_name = "lnkphm.online"

  zone_id = try(data.aws_route53_zone.this[0].zone_id, aws_route53_zone.this[0].zone_id)

  tags = {
    Name       = local.domain_name
    Terraform  = "true"
    Repository = "https://github.com/lnkphm/aws-acm"
  }
}

data "aws_route53_zone" "this" {
  count = local.use_existing_route53_zone ? 1 : 0

  name         = local.domain_name
  private_zone = false
}

resource "aws_route53_zone" "this" {
  count = !local.use_existing_route53_zone ? 1 : 0

  name = local.domain_name
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = local.domain_name
  zone_id     = local.zone_id

  subject_alternative_names = [
    "*.${local.domain_name}",
  ]

  wait_for_validation = true

  tags = local.tags
}
