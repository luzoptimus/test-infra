
################################################################################
# PostgreSQL Serverless v2
################################################################################

data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "14.17"
}

module "aurora_postgresql_v2" {
  source = "terraform-aws-modules/rds-aurora/aws"
  version = "v9.16.1" 

  name              = format("%s-rds-%s", var.environment, var.subproject)
  engine            = data.aws_rds_engine_version.postgresql.engine
  engine_mode       = "provisioned"
  engine_version    = data.aws_rds_engine_version.postgresql.version
  storage_encrypted = true
  master_username   = "postgres"
  database_name     = "OssUserDb"
  
  iam_database_authentication_enabled = true

  publicly_accessible =  var.environment == "optimus-dev" ? true : false

  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.database_subnet_group_name
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = [local.vpc_cidr, "0.0.0.0/0"] #, module.ecs_service.security_group_id
    }
  }

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  enable_http_endpoint = true

  serverlessv2_scaling_configuration = {
    min_capacity             = 0
    max_capacity             = 10
    seconds_until_auto_pause = 3600
  }

  instance_class = "db.serverless"
  instances = {
    one = {}
  }

  tags = local.tags
}

