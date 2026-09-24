# terraform-aws-ram-resource-share

Terraform module for an AWS Resource Access Manager (RAM) resource
share — sharing a resource this account owns with other AWS accounts or
an entire AWS Organization.

## Cost

RAM resource sharing carries no charge of its own — cost is whatever the
shared resource itself bills, wherever it is actually used. See the
sibling module that manages the resource being shared (e.g.
[`terraform-aws-transit-gateway`](https://github.com/kn47ytv9mv/terraform-aws-transit-gateway))
for its own Cost section.

## Design

RAM sharing is for letting other AWS accounts directly use a resource
this account owns — most commonly a transit gateway, so another account
can create its own VPC attachment to a hub it does not own. It is
distinct from every accepter-side module elsewhere in this family
(`terraform-aws-vpc-peering-connection-accepter`,
`terraform-aws-transit-gateway-peering-accepter`,
`terraform-aws-route53-vpc-association-authorization`): those authorize
one specific, already-named connection between two resources; RAM makes
a resource itself directly usable by other accounts, without a
one-to-one connection existing yet.

`principals` and `resource_arns` are plain list variables — a share
commonly has more than one principal and more than one shared resource,
and nothing outside this module ever needs to reference one specific
principal or resource association by its own ID.

### Why these are addressed by position

**Principal and resource associations are addressed by their position in the list, not by the
principal or ARN itself.** Terraform has to know every `for_each` key before it
plans, and a resource created in the same apply has no ARN yet, so keying
on it fails with *"the for_each set includes values derived from resource
attributes that cannot be determined until apply"* — which rules out the
ordinary case of building both together. A list's length is known even
when none of its elements are, so `count` plans cleanly.

The consequence worth knowing: **reordering or removing an entry shifts
every later one's address**, and Terraform will plan to destroy and
recreate them. Append rather than insert, and use `moved` blocks when an
existing deployment has to be reshuffled.

## Usage

```hcl
module "transit_gateway_share" {
  source = "kn47ytv9mv/ram-resource-share/aws"

  name          = "shared-transit-gateway"
  principals    = ["123456789012", "234567890123"]
  resource_arns = [module.transit_gateway.arn]
}
```

Or directly from this repository, sharing with an entire organization:

```hcl
module "transit_gateway_share" {
  source = "github.com/kn47ytv9mv/terraform-aws-ram-resource-share"

  name          = "org-transit-gateway"
  principals    = ["arn:aws:organizations::123456789012:organization/o-exampleorgid"]
  resource_arns = [module.transit_gateway.arn]
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.0 |
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| name | The name of the resource share. If null, a random UUID is used. | `null` | no |
| allow_external_principals | Whether principals outside this account's AWS Organization can be associated with this share. If null, AWS's own default applies. | `null` | no |
| principals | Principals to share resources with: AWS account IDs, an AWS Organizations organization ARN, or an AWS Organizations organizational unit ARN. | `[]` | no |
| resource_arns | ARNs of the resources to share (e.g. a transit gateway's ARN, so attached accounts can create their own VPC attachments to it). | `[]` | no |
| tags | A map of tags to assign to the resource share. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID of the resource share. |
| arn | The ARN of the resource share. |
| name | The name of the resource share. |

## License

MIT — see [LICENSE.md](LICENSE.md).
