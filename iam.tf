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

data "aws_iam_policy" "AmazonRoute53FullAccess" {
  name = "AmazonRoute53FullAccess"
}

resource "aws_iam_group_policy_attachment" "IAMFullAccess_attach" {
  group      = aws_iam_group.admin.name
  policy_arn = data.aws_iam_policy.IAMFullAccess.arn
}

resource "aws_iam_group_policy_attachment" "AmazonRoute53FullAccess_attach" {
  group      = aws_iam_group.admin.name
  policy_arn = data.aws_iam_policy.AmazonRoute53FullAccess.arn
}

