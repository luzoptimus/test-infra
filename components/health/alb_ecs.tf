locals {
  # Generar target groups desde los servicios ECS
  alb_target_groups = {
    for service_key, service in var.ecs_services : "${service_key}-tg" => {
      name_prefix                       = substr("${service.name}_", 0, 6)
      backend_protocol                  = "HTTP"
      backend_port                      = 8080
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true
      
      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200,404"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }
      
      create_attachment = false
    }
  }

  # Generar reglas de path-based routing - ASEGURAR QUE path_patterns existe
alb_path_rules = {
  for idx, service_key in keys(var.ecs_services) :
  service_key => {
    priority = idx + 1

    actions = [{
        forward = {
        target_group_key = "${service_key}-tg"
        }
    }]

    conditions = [{
      path_pattern = {
        values = coalesce(lookup(var.ecs_services[service_key], "path_patterns", null), ["/${service_key}/*"])
      }
    }]
  }
  if length(coalesce(lookup(var.ecs_services[service_key], "path_patterns", ["/${service_key}/*"]))) > 0
}
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.0"

  name               = local.name
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      # IMPORTANTE: El default_action debe existir
      forward = {
        target_group_key = "${keys(var.ecs_services)[0]}-tg"
      }

      # Rules para path-based routing
      rules = local.alb_path_rules

    }
  }

  # Target Groups
  target_groups = local.alb_target_groups

  tags = local.tags
}