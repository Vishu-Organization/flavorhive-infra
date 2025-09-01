resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.dev_account_id}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": [
            "repo:Vishu-Organization/flavorhive-infra:ref:refs/heads/main",
            "repo:Vishu-Organization/flavorhive-infra:ref:refs/pull/*"
          ]
        },
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
})

  tags = {
    Environment = "FlavorHive"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.this.name
  policy_arn = var.policy_arn
}
