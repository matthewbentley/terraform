provider "aws" {
  region = var.region
}

resource "aws_route53_zone" "mtbwtf" {
  name = "mtb.wtf"
}

resource "aws_route53_record" "test" {
  zone_id = aws_route53_zone.mtbwtf.zone_id
  name = "mtf.wtf"
  type = "A"
  ttl = "300"
  records = ["0.0.0.0"]
}
