resource "aws_iam_user" "terraform_infra_user" {
  name = "terraform-infra-user"
}

data "template_file" "iam_policy" {
  template = file("${path.module}/iam_policy.template.json")
  vars = {
    terraform_state_bucket = aws_s3_bucket.terraform_state.bucket
    terraform_lock_table   = aws_dynamodb_table.terraform_locks.name
  }
}

resource "aws_iam_user_policy" "terraform_infra_user" {
  name   = "terraform-infra-management"
  user   = aws_iam_user.terraform_infra_user.name
  policy = data.template_file.iam_policy.rendered
}

resource "aws_iam_access_key" "terraform_infra_user" {
  user = aws_iam_user.terraform_infra_user.name
}

output "secret_key" {
  value     = aws_iam_access_key.terraform_infra_user.secret
  sensitive = true
}

output "access_key" {
  value = aws_iam_access_key.terraform_infra_user.id
}
