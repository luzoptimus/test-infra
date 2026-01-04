variable "default_tags" {
  type        = map(string)
  description = "A map of default tags to apply to all taggable resources within the module."
}

variable "domain_name" {
  type        = string
  description = "Domain name of the Route53 hosted zone to use for ACM certificate validation."
}

variable "domain_name_acm" {
  type        = string
  description = "Domain name of the Route53 hosted zone to use for ACM certificate validation."
  default     = "optimusbrand.io"
}

variable "private_zone" {
  type        = bool
  description = "Whether the Route53 hostedzone is private or public."
  default     = false
}

variable "additional_acm_names" {
  type        = list(string)
  description = "Additional domain names for the environment to create ACM certificates"
  default     = []
}
