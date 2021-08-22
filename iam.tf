resource "aws_iam_user" "tfcloud" {
  name = "tfcloud"
}

resource "aws_iam_user" "bentley" {
  name = "bentley"
}

resource "aws_iam_group" "admin" {
  name = "admin"
}

resource "aws_iam_group_membership" "tfcloud_admin" {
  name = "admin-membership"

  users = [aws_iam_user.tfcloud.name, aws_iam_user.bentley.name]

  group = aws_iam_group.admin.name
}

data "aws_iam_policy" "IAMFullAccess" {
  name = "IAMFullAccess"
}

data "aws_iam_policy" "AmazonRoute53DomainsReadOnlyAccess" {
  name = "AmazonRoute53DomainsReadOnlyAccess"
}

data "aws_iam_policy" "AmazonRoute53AutoNamingFullAccess" {
  name = "AmazonRoute53AutoNamingFullAccess"
}

resource "aws_iam_group_policy_attachment" "IAMFullAccess_attach" {
  group = aws_iam_group.admin.name
  policy_arn = data.aws_iam_policy.IAMFullAccess.arn
}

resource "aws_iam_group_policy_attachment" "AmazonRoute53AutoNamingFullAccess_attach" {
  group = aws_iam_group.admin.name
  policy_arn = data.aws_iam_policy.AmazonRoute53AutoNamingFullAccess.arn
}

resource "aws_iam_group_policy_attachment" "AmazonRoute53DomainsReadOnlyAccess_attach" {
  group = aws_iam_group.admin.name
  policy_arn = data.aws_iam_policy.AmazonRoute53DomainsReadOnlyAccess.arn
}
  
