variable "name" {
  default     = null
  description = "The name of the resource share. If null, a random UUID is used."
}

variable "allow_external_principals" {
  default     = null
  description = "Whether principals outside this account's AWS Organization can be associated with this share. If null, AWS's own default applies."
}

variable "principals" {
  default     = []
  description = "Principals to share resources with: AWS account IDs, an AWS Organizations organization ARN, or an AWS Organizations organizational unit ARN."
}

variable "resource_arns" {
  default     = []
  description = "ARNs of the resources to share (e.g. a transit gateway's ARN, so attached accounts can create their own VPC attachments to it)."
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the resource share."
}
