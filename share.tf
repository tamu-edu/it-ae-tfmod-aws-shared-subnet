####
# Resource shares
####

resource "aws_ram_resource_share" "share_to_account" {
  name                      = "share-subnets-to-acct-${var.account_name}"
  allow_external_principals = false
#   provider                  = aws.us-east-1
}

resource "aws_ram_principal_association" "aws_account" {
  principal          = var.account_id
  resource_share_arn = aws_ram_resource_share.share_to_account.arn
#   provider           = aws.us-east-1
}
