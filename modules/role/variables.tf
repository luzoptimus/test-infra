#variables generales de los modulos
variable "region" {
  description = "Region"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  type        = string
  description = "Id account owner "
}

variable "namespace" {
  description = "Iniciales de Banco de Bogota"
  type        = string
  default     = "bdb"
}

variable "environment" {
  description = "Ambiente sobre el cual se trabaja (qa, st, prod)"
  type        = string
  default     = "qa"
}

variable "project" {
  description = "Nombre del equipo/producto/proyecto"
  type        = string
}  

variable "tags" {
  description = "Lista de tags asignados a todos los recursos"
  type        = map(string)
  default     = {}
}


#variables especificos a tf-role
variable "assume_role_policy" {
  description = "JSON string representation of the IAM policy for this role asume"
  default  = ""
}

variable "aws_iam_policy_document" {
  description = "JSON string representation of the IAM policy for this role"
  type     = list
  default  = []
}

variable "type" {
  type        = string
  description = "type role"
}
 
variable "policy_arn" {
  description = "policy arn IAM policy for this role"
  type     = list
  default  = []
}

variable "role_name" {
  description = "Role Name para aplicar politicas"
  default  = null
}

variable "role_terra" {
  description = "Role to create role "
  default  = "OrgPrimaryCrossAccount"
  }

  variable "enable" {
  type        = bool
  description = "enable to create role"
  default  = true
  }

  ##Roles Anywhere
   variable "enabled_anywhere" {
  type        = bool
  description = "enable to create role"
  default  = false
  }

  variable "kms_key_id" {
  type    = string
  default = "NA"
}

variable "recovery_window" {
  type    = string
  default = "7"
}

variable "source_type" {
  type    = string
  default = "CERTIFICATE_BUNDLE"
}

variable "acm_pca_arn" {
  type    = string
  default = null
}
