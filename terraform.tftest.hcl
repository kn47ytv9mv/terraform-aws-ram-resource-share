mock_provider "aws" {
  mock_resource "aws_ram_resource_share" {
    defaults = {
      arn = "arn:aws:ram:us-east-1:111111111111:resource-share/00000000-0000-0000-0000-000000000000"
    }
  }
}

run "name_falls_back_to_random_uuid_when_unset" {
  command = apply

  assert {
    condition     = aws_ram_resource_share.resource.name == random_uuid.resource.id
    error_message = "name should fall back to the random UUID when var.name is left unset."
  }
}

run "explicit_name_is_used_as_is" {
  command = plan

  variables {
    name = "shared-transit-gateway"
  }

  assert {
    condition     = aws_ram_resource_share.resource.name == "shared-transit-gateway"
    error_message = "An explicitly supplied name should be used as-is, not the random UUID fallback."
  }
}

run "principals_and_resources_create_associations" {
  command = plan

  variables {
    name          = "shared-transit-gateway"
    principals    = ["123456789012", "234567890123"]
    resource_arns = ["arn:aws:ec2:us-east-1:111111111111:transit-gateway/tgw-0123456789abcdef0"]
  }

  assert {
    condition     = length(aws_ram_principal_association.resource) == 2
    error_message = "One principal association should be created per entry in principals."
  }

  assert {
    condition     = aws_ram_principal_association.resource[0].principal == "123456789012"
    error_message = "Each principal association should be keyed by its own principal value, not an index."
  }

  assert {
    condition     = length(aws_ram_resource_association.resource) == 1
    error_message = "One resource association should be created per entry in resource_arns."
  }
}

run "no_principals_or_resources_creates_bare_share" {
  command = plan

  variables {
    name = "empty-share"
  }

  assert {
    condition     = length(aws_ram_principal_association.resource) == 0
    error_message = "No principals were given, so none should be created."
  }

  assert {
    condition     = length(aws_ram_resource_association.resource) == 0
    error_message = "No resource_arns were given, so none should be created."
  }
}

run "readme_default_example" {
  command = plan

  variables {
    name          = "shared-transit-gateway"
    principals    = ["123456789012", "234567890123"]
    resource_arns = ["arn:aws:ec2:us-east-1:111111111111:transit-gateway/tgw-0123456789abcdef0"]
  }
}

run "readme_organization_example" {
  command = plan

  variables {
    name          = "org-transit-gateway"
    principals    = ["arn:aws:organizations::123456789012:organization/o-exampleorgid"]
    resource_arns = ["arn:aws:ec2:us-east-1:111111111111:transit-gateway/tgw-0123456789abcdef0"]
  }
}
