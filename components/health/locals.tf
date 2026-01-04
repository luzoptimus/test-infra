data "aws_availability_zones" "available" {}

locals {
  region = var.region
  name   = format("%s-ecs-%s", var.environment, var.subproject)

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  container_name = "user"
  container_port = 8080

  tags = {
    Project       = local.name
    By            = "Terraform"
    env           = var.environment
  }
}
