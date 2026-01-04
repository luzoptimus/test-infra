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
# variable "assume_role_policy" {
#   description = "JSON string representation of the IAM policy for this role asume"
# }

variable "aws_iam_policy_document" {
  description = "JSON string representation of the IAM policy for this role"
  type     = list
  default  = []
}

# variable "type" {
#   type        = string
#   description = "type role"
# }
 
variable "policy_arn" {
  description = "policy arn IAM policy for this role"
  type     = list
  default  = []
}


variable "accountIds" {
  type        = list(string)
  description = "Lista de cuentas del grupo Agil"
}