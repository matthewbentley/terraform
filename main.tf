provider "aws" {
  region = var.region
}

resource "aws_route53_zone" "mtbwtf" {
  name = "mtb.wtf"
}

resource "aws_route53_record" "test" {
  zone_id = aws_route53_zone.mtbwtf.zone_id
  name = "@"
  type = "A"
  ttl = "300"
  records = ["0.0.0.0"]
}

resource "aws_route53_record" "mtbwtf_spf" {
  zone_id = aws_route53_zone.mtbwtf.zone_id
  name = "@"
  type = "TXT"
  ttl = "300"
  records = ["v=spf1 redirect=icloud.com", "apple-domain=Rvhs2XH3aDeAY18g"]
}

resource "aws_route53_record" "mtbwtf_dkim" {
  zone_id = aws_route53_zone.mtbwtf.zone_id
  name = "sig1._domainkey"
  type = "CNAME"
  ttl = "300"
  records = ["sig1.dkim.mtb.wtf.at.icloudmailadmin.com."]
}

resource "aws_route53_record" "mtbwtf_mx" {
  zone_id = aws_route53_zone.mtbwtf.zone_id
  name = "@"
  type = "MX"
  ttl = "300"
  records = ["10 mx01.mail.icloud.com.", "20 mx02.mail.icloud.com."]
}

locals {
  domain_name = "mtb.wtf"
  use_failback = false
  failback_list = [
    "aws-dns-1",
    "aws-dns-2",
    "aws-dns-3",
    "aws-dns-4",
  ]
}

resource "null_resource" "aws_domain_com_nameservers" {
  triggers = {
    nameservers = join(", ",sort(  local.use_failback == false ? aws_route53_zone.mtbwtf.name_servers : [ for ns in local.failback_list:  ns ]  ))
  }

  provisioner "local-exec" {
    command = "aws --region us-east-1 route53domains update-domain-nameservers  --domain-name ${local.domain_name} --nameservers  ${join(" ",formatlist(" Name=%s",sort(  local.use_failback == false ? aws_route53_zone.mtbwtf.name_servers : [ for ns in local.failback_list:  ns ]  )))}   "
  }
}
