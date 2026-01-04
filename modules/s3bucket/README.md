# nx-tf-module-s3bucket
Infrastructure Repository to Store Terraform s3bucket Module

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.54 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.54 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_access_point.s3bucket_static_content](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_access_point) | resource |
| [aws_s3_bucket.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_ownership_controls.bucket_owner_enforced_main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_ownership_controls.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acl"></a> [acl](#input\_acl) | ACL to set on the bucket. Defaults to private | `string` | `"private"` | no |
| <a name="input_aws_s3_access_point"></a> [aws\_s3\_access\_point](#input\_aws\_s3\_access\_point) | provision of the access point | `bool` | `false` | no |
| <a name="input_bucket_key_enabled"></a> [bucket\_key\_enabled](#input\_bucket\_key\_enabled) | Boolean to toggle bucket key enablement | `bool` | `true` | no |
| <a name="input_bucket_logging_target"></a> [bucket\_logging\_target](#input\_bucket\_logging\_target) | Map of S3 bucket access logging target properties | `map(string)` | `{}` | no |
| <a name="input_component"></a> [component](#input\_component) | The name of the tfscaffold component | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | A map of default tags to apply to all taggable resources within the component | `map(string)` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the tfscaffold environment | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Boolean to toggle force destroy of bucket. Defaults to true; should be changed in exceptional circumstances | `bool` | `true` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of default encryption KMS key for this bucket. If omitted, will use AES256 | `string` | `null` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | Object representing the lifecycle rules of the bucket | <pre>object({<br/>    prefix = string<br/><br/>    noncurrent_version_transition = list(object({<br/>      days          = string<br/>      storage_class = string<br/>    }))<br/><br/>    transition = list(object({<br/>      days          = string<br/>      storage_class = string<br/>    }))<br/><br/>    noncurrent_version_expiration = object({<br/>      days = string<br/>    })<br/><br/>    expiration = object({<br/>      days = string<br/>    })<br/><br/>    abort_incomplete_multipart_upload = object({<br/>      days = number<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_module"></a> [module](#input\_module) | The variable encapsulating the name of this module | `string` | `"s3bucket"` | no |
| <a name="input_name"></a> [name](#input\_name) | The variable encapsulating the name of this bucket | `string` | n/a | yes |
| <a name="input_object_ownership"></a> [object\_ownership](#input\_object\_ownership) | Ownership of objects written to the bucket | `string` | `"BucketOwnerEnforced"` | no |
| <a name="input_policy_documents"></a> [policy\_documents](#input\_policy\_documents) | A list of JSON policies to use to build the bucket policy | `list(string)` | `[]` | no |
| <a name="input_policy_documents_1"></a> [policy\_documents\_1](#input\_policy\_documents\_1) | A list of JSON policies to use to build the bucket policy | <pre>set(object({<br/>    name_sid                       = string<br/>    actions            = optional(list(string), [])<br/>    principals_type                 = optional(string, "AWS")<br/>    principals_identifiers                = optional(list(string), [])<br/>    conditions             = optional(set(object({ <br/>      conditions_test        = optional(string, "StringLike")<br/>      conditions_variable = optional(string, "aws:PrincipalArn")<br/>      conditions_values = optional(list(string), [])<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_project"></a> [project](#input\_project) | The name of the tfscaffold project | `string` | n/a | yes |
| <a name="input_public_access"></a> [public\_access](#input\_public\_access) | Object representing the public access rules of the bucket | <pre>object({<br/>    block_public_acls       = bool<br/>    block_public_policy     = bool<br/>    ignore_public_acls      = bool<br/>    restrict_public_buckets = bool<br/>  })</pre> | <pre>{<br/>  "block_public_acls": true,<br/>  "block_public_policy": true,<br/>  "ignore_public_acls": true,<br/>  "restrict_public_buckets": true<br/>}</pre> | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Toggle for versioning the bucket. Defaults to true | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acl"></a> [acl](#output\_acl) | ID of the S3 bucket ACL resource in case the object property is not BucketOwnerEnforced. |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the bucket. |
| <a name="output_bucket"></a> [bucket](#output\_bucket) | Name of the bucket. |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | Bucket domain name. Will be of format bucketname.s3.amazonaws.com |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | The bucket region-specific domain name. The bucket domain name including the region name. |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | Route 53 Hosted Zone ID for this bucket's region. |
| <a name="output_id"></a> [id](#output\_id) | Name of the bucket. |
| <a name="output_policy"></a> [policy](#output\_policy) | Text of the policy |
| <a name="output_region"></a> [region](#output\_region) | AWS region this bucket resides in. |

## Tags
| Name | Description | Comments |
|------|-------------|-------------|
|  <a name="tags_0.0.1"></a> [0.0.1](#tags_0.0.1) | Initial| n/a |
|  <a name="tags_0.0.2"></a> [0.0.2](#tags_0.0.2) | dependencies for ACL changed | n/a |
|  <a name="tags_0.0.3"></a> [0.0.3](#tags_0.0.3) | lifecycle conditional in filter section | n/a |
|  <a name="tags_0.0.4"></a> [0.0.4](#tags_0.0.4) | iam_policy_document modified to improve s3 refactor | n/a |