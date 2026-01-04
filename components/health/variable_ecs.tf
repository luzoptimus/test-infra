variable "ecs_services" {
  description = "Mapa de servicios ECS con sus configuraciones"
  type = map(object({
    # Service Configuration
    name          = string

    # Load Balancer Configuration
    container_name = string
    container_port = optional(number, 8080)
    path_patterns  = list(string)  # Patterns para path-based routing

    # Container Definitions
    containers = map(object({
      image                    = string
      cpu                      = optional(number)
      memory                   = optional(number)
      memory_reservation       = optional(number)
      essential                = optional(bool, true)
      readonly_root_filesystem = optional(bool, false)
      privileged               = optional(bool, false)
      user                     = optional(string)
      working_directory        = optional(string)
      command                  = optional(list(string))
      entrypoint               = optional(list(string))

      # Port Mappings
      port_mappings = list(object({
        name          = optional(string)
        containerPort = number
        hostPort      = optional(number)
        protocol      = optional(string, "tcp")
        appProtocol   = optional(string)
      }))

      # Mount Points
      mount_points = optional(list(object({
        sourceVolume  = string
        containerPath = string
        readOnly      = optional(bool, false)
      })), [])

      # Environment Variables
      environment = optional(list(object({
        name  = string
        value = string
      })), [])

      # Secrets
      secrets = optional(list(object({
        name      = string
        valueFrom = string
      })), [])

      # CloudWatch Logs
      enable_cloudwatch_logging              = optional(bool, true)
      create_cloudwatch_log_group            = optional(bool, true)
      cloudwatch_log_group_retention_in_days = optional(number, 7)

      # Health Check
      health_check = optional(object({
        command     = list(string)
        interval    = optional(number, 30)
        timeout     = optional(number, 5)
        retries     = optional(number, 3)
        startPeriod = optional(number, 0)
      }))

      # Dependencies
      depends_on = optional(list(object({
        containerName = string
        condition     = string
      })), [])

      # Ulimits
      ulimits = optional(list(object({
        name      = string
        softLimit = number
        hardLimit = number
      })), [])
    }))

  }))
  default = {}
}