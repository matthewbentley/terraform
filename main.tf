provider "aws" {
  region = var.region
}

resource "aws_route53_zone" "mtbwtf" {
  name = "mtb.wtf"
}

resource "aws_route53_record" "test" {
  zone_id = aws_route53_zone.mtbwtf.zone_id
  name    = "mtb.wtf."
  type    = "A"
  ttl     = "300"
  records = ["0.0.0.0"]
}

resource "aws_route53_record" "mtbwtf_spf" {
  zone_id = aws_route53_zone.mtbwtf.zone_id
  name    = "mtb.wtf."
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 redirect=icloud.com", "apple-domain=Rvhs2XH3aDeAY18g"]
}

resource "aws_route53_record" "mtbwtf_dkim" {
  zone_id = aws_route53_zone.mtbwtf.zone_id
  name    = "sig1._domainkey"
  type    = "CNAME"
  ttl     = "300"
  records = ["sig1.dkim.mtb.wtf.at.icloudmailadmin.com."]
}

resource "aws_route53_record" "mtbwtf_mx" {
  zone_id = aws_route53_zone.mtbwtf.zone_id
  name    = "mtb.wtf."
  type    = "MX"
  ttl     = "300"
  records = ["10 mx01.mail.icloud.com.", "20 mx02.mail.icloud.com."]
}

locals {
  domain_name  = "mtb.wtf"
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
    nameservers = join(", ", sort(local.use_failback == false ? aws_route53_zone.mtbwtf.name_servers : [for ns in local.failback_list : ns]))
  }

  provisioner "local-exec" {
    command = "aws --region us-east-1 route53domains update-domain-nameservers  --domain-name ${local.domain_name} --nameservers  ${join(" ", formatlist(" Name=%s", sort(local.use_failback == false ? aws_route53_zone.mtbwtf.name_servers : [for ns in local.failback_list : ns])))}   "
  }
}

output "mtbwtf_NS" {
  value = aws_route53_zone.mtbwtf.name_servers
}

resource "digitalocean_droplet" "mc" {
  image         = "ubuntu-20-04-x64"
  name          = "mc.mtb.wtf"
  region        = "nyc3"
  size          = "s-4vcpu-8gb-intel"
  monitoring    = "true"
  ipv6          = "true"
  droplet_agent = "true"
  ssh_keys      = [digitalocean_ssh_key.m1_macos.fingerprint]
}

resource "digitalocean_ssh_key" "m1_macos" {
  name       = "bentley m1 macos"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEj3xP1wGv5tdCwH0tkuy/EPJm7tIAWDZlJVCb1EGv4Z bentley@Matthews-MacBook-Pro.local"
}

resource "aws_route53_record" "mtbwtf_mc_a" {
  zone_id = aws_route53_zone.mtbwtf.zone_id
  name    = "mc.mtb.wtf."
  type    = "A"
  ttl     = "300"
  records = [digitalocean_droplet.mc.ipv4_address]
}

resource "aws_route53_record" "mtbwtf_mc_aaaa" {
  zone_id = aws_route53_zone.mtbwtf.zone_id
  name    = "mc.mtb.wtf."
  type    = "AAAA"
  ttl     = "300"
  records = [digitalocean_droplet.mc.ipv6_address]
}

resource "digitalocean_firewall" "mc" {
  # TODO: add mc ports

  name        = "MC firewall"
  droplet_ids = [digitalocean_droplet.mc.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
