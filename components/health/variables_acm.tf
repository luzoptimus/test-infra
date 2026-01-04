
variable "domain_name_acm" {
  type        = string
  description = "Domain name of the Route53 hosted zone to use for ACM certificate validation."
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
