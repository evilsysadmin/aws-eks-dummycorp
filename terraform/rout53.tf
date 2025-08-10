data "aws_route53_zone" "main" {
  name         = "evilsysadmin.click"
  private_zone = false
}

