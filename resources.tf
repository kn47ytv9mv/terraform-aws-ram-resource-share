resource "random_uuid" "resource" {}

resource "aws_ram_resource_share" "resource" {
  name                      = coalesce(var.name, random_uuid.resource.id)
  allow_external_principals = var.allow_external_principals

  tags = merge(var.tags, { name = "share" })
}

resource "aws_ram_principal_association" "resource" {
  count = length(var.principals)

  resource_share_arn = aws_ram_resource_share.resource.arn
  principal          = var.principals[count.index]
}

resource "aws_ram_resource_association" "resource" {
  count = length(var.resource_arns)

  resource_share_arn = aws_ram_resource_share.resource.arn
  resource_arn       = var.resource_arns[count.index]
}

output "id" {
  description = "The ID of the resource share."
  value       = aws_ram_resource_share.resource.id
}

output "name" {
  description = "The name of the resource share."
  value       = aws_ram_resource_share.resource.name
}

output "arn" {
  description = "The ARN of the resource share."
  value       = aws_ram_resource_share.resource.arn
}
