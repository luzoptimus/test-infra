
module "ecs_service" {
  for_each = var.ecs_services
  source   = "terraform-aws-modules/ecs/aws//modules/service"
  version  = "6.6.1"

  # Service
  name        = each.value.name
  cluster_arn = module.ecs.arn

  # Task Definition
  iam_role_name            = "dev-health-${each.value.name}"
  requires_compatibilities = ["EC2"]
  capacity_provider_strategy = {
    # On-demand instances
    "ex_1_${var.environment}" = {
      capacity_provider = module.ecs.autoscaling_capacity_providers["ex_1_${var.environment}"].name
      weight            = 1
      base              = 1
    }
  }
  
  volume_configuration = {
    name = "ebs-volume"
    managed_ebs_volume = {
      encrypted        = true
      file_system_type = "xfs"
      size_in_gb       = 5
      volume_type      = "gp3"
    }
  }

  volume = {
    my-vol = {},
    ebs-volume = {
      name                = "ebs-volume"
      configure_at_launch = true
    }
  }

  # Container definition(s)
  container_definitions = {
    for container_name, container in each.value.containers : container_name => merge(
      {
        image                    = container.image
        essential                = container.essential
        readonly_root_filesystem = container.readonly_root_filesystem
      },
      container.cpu != null ? { cpu = container.cpu } : {},
      container.memory != null ? { memory = container.memory } : {},
      container.memory_reservation != null ? { memory_reservation = container.memory_reservation } : {},
      container.privileged != null ? { privileged = container.privileged } : {},
      container.user != null ? { user = container.user } : {},
      container.working_directory != null ? { working_directory = container.working_directory } : {},
      container.command != null ? { command = container.command } : {},
      container.entrypoint != null ? { entrypoint = container.entrypoint } : {},

      # Port Mappings
      {
        portMappings = [
          for pm in container.port_mappings : merge(
            { containerPort = pm.containerPort },
            pm.name != null ? { name = pm.name } : {},
            pm.hostPort != null ? { hostPort = pm.hostPort } : { hostPort = pm.containerPort },
            { protocol = pm.protocol },
            pm.appProtocol != null ? { appProtocol = pm.appProtocol } : {}
          )
        ]
      },

      # Mount Points
      length(container.mount_points) > 0 ? {
        mountPoints = [
          for mp in container.mount_points : {
            sourceVolume  = mp.sourceVolume
            containerPath = mp.containerPath
            readOnly      = mp.readOnly
          }
        ]
      } : {},

      # Environment Variables
      length(container.environment) > 0 ? {
        environment = container.environment
      } : {},

      # Secrets
      length(container.secrets) > 0 ? {
        secrets = container.secrets
      } : {},

      # CloudWatch Logging
      container.enable_cloudwatch_logging ? {
        enable_cloudwatch_logging              = container.enable_cloudwatch_logging
        create_cloudwatch_log_group            = container.create_cloudwatch_log_group
        cloudwatch_log_group_name              = "/aws/ecs/${each.value.name}/${container_name}-${var.environment}"
        cloudwatch_log_group_retention_in_days = container.cloudwatch_log_group_retention_in_days
      } : {},

      # Health Check
      container.health_check != null ? {
        healthCheck = container.health_check
      } : {},

      # Dependencies
      length(container.depends_on) > 0 ? {
        dependsOn = container.depends_on
      } : {},

      # Ulimits
      length(container.ulimits) > 0 ? {
        ulimits = container.ulimits
      } : {}
    )
  }
  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["${each.key}-tg"].arn
      container_name   = each.value.container_name
      container_port   = each.value.container_port
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_ingress_rules = {
    alb_http = {
      from_port                    = local.container_port
      description                  = "Service port"
      referenced_security_group_id = module.alb.security_group_id
    }
  }

  tags = local.tags

  ignore_task_definition_changes = true
}
