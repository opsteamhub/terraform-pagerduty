# Complete PagerDuty Configuration Example
# This example demonstrates a full setup with multiple services, users, schedules, and integrations

terraform {
  required_providers {
    pagerduty = {
      source  = "pagerduty/pagerduty"
      version = "3.23.1"
    }
  }
}

# Variables
variable "pagerduty_token" {
  description = "PagerDuty API token"
  type        = string
  sensitive   = true
}

variable "pagerduty_user_token" {
  description = "PagerDuty user token"
  type        = string
  sensitive   = true
}

variable "slack_workspace_id" {
  description = "Slack workspace ID for integrations"
  type        = string
  default     = "T1234567890"
}

variable "slack_channel_id" {
  description = "Slack channel ID for notifications"
  type        = string
  default     = "C1234567890"
}

# Complete PagerDuty configuration
module "pagerduty_complete" {
  source = "../"

  pagerduty_token      = var.pagerduty_token
  pagerduty_user_token = var.pagerduty_user_token

  # Multiple services with different configurations
  services = {
    "production-api" = {
      description             = "Production API Service - Critical"
      auto_resolve_timeout    = 7200   # 2 hours
      acknowledgement_timeout = 300    # 5 minutes
      alert_creation          = "create_alerts_and_incidents"
      
      rules = [
        {
          name                        = "Primary Escalation"
          escalation_delay_in_minutes = 10
          targets = [
            {
              type   = "schedule_reference"
              target = "primary-schedule"
            }
          ]
        },
        {
          name                        = "Secondary Escalation"
          escalation_delay_in_minutes = 15
          targets = [
            {
              type   = "schedule_reference"
              target = "secondary-schedule"
            }
          ]
        }
      ]
      
      slack_integration          = true
      workspace_id              = var.slack_workspace_id
      channel_id                = var.slack_channel_id
      notification_type         = "responder"
      service_integration       = true
      service_integration_vendor = "Prometheus"
    }

    "staging-environment" = {
      description             = "Staging Environment Service"
      auto_resolve_timeout    = 14400  # 4 hours
      acknowledgement_timeout = 900    # 15 minutes
      alert_creation          = "create_alerts_and_incidents"
      
      rules = [
        {
          name                        = "Development Team"
          escalation_delay_in_minutes = 30
          targets = [
            {
              type   = "user_reference"
              target = "dev-lead@company.com"
            }
          ]
        }
      ]
      
      service_integration       = true
      service_integration_vendor = "Prometheus"
    }

    "database-cluster" = {
      description             = "Database Cluster Service"
      auto_resolve_timeout    = 3600   # 1 hour
      acknowledgement_timeout = 180    # 3 minutes
      alert_creation          = "create_alerts_and_incidents"
      
      rules = [
        {
          name                        = "DBA Team"
          escalation_delay_in_minutes = 5
          targets = [
            {
              type   = "schedule_reference"
              target = "dba-schedule"
            }
          ]
        }
      ]
      
      slack_integration          = true
      workspace_id              = var.slack_workspace_id
      channel_id                = var.slack_channel_id
      service_integration       = true
      service_integration_vendor = "Prometheus"
    }
  }

  # Multiple users with different roles and timezones
  users = {
    "john.doe@company.com" = {
      user_name      = "John Doe"
      user_email     = "john.doe@company.com"
      user_role      = "admin"
      user_time_zone = "America/New_York"
      country_code   = "+1"
      phone          = "5551234567"
      label          = "Work"
    }

    "jane.smith@company.com" = {
      user_name      = "Jane Smith"
      user_email     = "jane.smith@company.com"
      user_role      = "user"
      user_time_zone = "America/Los_Angeles"
      country_code   = "+1"
      phone          = "5559876543"
      label          = "Mobile"
    }

    "dev-lead@company.com" = {
      user_name      = "Development Lead"
      user_email     = "dev-lead@company.com"
      user_role      = "user"
      user_time_zone = "Europe/London"
      country_code   = "+44"
      phone          = "7700123456"
      label          = "Work"
    }

    "dba@company.com" = {
      user_name      = "Database Administrator"
      user_email     = "dba@company.com"
      user_role      = "user"
      user_time_zone = "America/Chicago"
      country_code   = "+1"
      phone          = "5555551234"
      label          = "Work"
    }

    "ops-manager@company.com" = {
      user_name      = "Operations Manager"
      user_email     = "ops-manager@company.com"
      user_role      = "manager"
      user_time_zone = "America/New_York"
      country_code   = "+1"
      phone          = "5554567890"
      label          = "Work"
    }
  }

  # Multiple schedules with different rotation patterns
  schedule = {
    "primary-schedule" = {
      name      = "Primary On-Call Schedule"
      time_zone = "America/New_York"
      
      layers = [
        {
          name                         = "Primary Layer"
          start                        = "2024-01-01T08:00:00Z"
          rotation_virtual_start       = "2024-01-01T08:00:00Z"
          rotation_turn_length_seconds = 604800  # 1 week
          
          users = {
            "primary1" = "john.doe@company.com"
            "primary2" = "jane.smith@company.com"
          }
          
          restriction = [
            {
              create_restriction = true
              type              = "weekly_restriction"
              start_time_of_day = "08:00:00"
              duration_seconds  = 36000  # 10 hours (8 AM to 6 PM)
              start_day_of_week = 1      # Monday
            }
          ]
        }
      ]
    }

    "secondary-schedule" = {
      name      = "Secondary Escalation Schedule"
      time_zone = "America/New_York"
      
      layers = [
        {
          name                         = "Secondary Layer"
          start                        = "2024-01-01T18:00:00Z"
          rotation_virtual_start       = "2024-01-01T18:00:00Z"
          rotation_turn_length_seconds = 1209600  # 2 weeks
          
          users = {
            "secondary1" = "ops-manager@company.com"
            "secondary2" = "dev-lead@company.com"
          }
          
          restriction = [
            {
              create_restriction = true
              type              = "weekly_restriction"
              start_time_of_day = "18:00:00"
              duration_seconds  = 50400  # 14 hours (6 PM to 8 AM next day)
              start_day_of_week = 1      # Monday
            }
          ]
        }
      ]
    }

    "dba-schedule" = {
      name      = "Database Administrator Schedule"
      time_zone = "America/Chicago"
      
      layers = [
        {
          name                         = "DBA Layer"
          start                        = "2024-01-01T00:00:00Z"
          rotation_virtual_start       = "2024-01-01T00:00:00Z"
          rotation_turn_length_seconds = 86400   # 24 hours
          
          users = {
            "dba1" = "dba@company.com"
            "dba2" = "john.doe@company.com"
          }
        }
      ]
    }
  }

  update_schedule = true
}

# Outputs for integration keys and service information
output "all_integration_keys" {
  description = "All service integration keys for monitoring tools"
  value       = module.pagerduty_complete.pd_int
  sensitive   = true
}

output "service_integrations" {
  description = "Complete service integration objects"
  value       = module.pagerduty_complete.service_integration
  sensitive   = true
}

# Example of how to use the integration key in Prometheus Alertmanager
output "prometheus_alertmanager_config_example" {
  description = "Example Prometheus Alertmanager configuration snippet"
  value = <<-EOT
    # Add this to your Prometheus Alertmanager configuration:
    # 
    # receivers:
    #   - name: 'pagerduty-production-api'
    #     pagerduty_configs:
    #       - routing_key: '${try(module.pagerduty_complete.pd_int["production-api"].pagerduty_key, "INTEGRATION_KEY_HERE")}'
    #         description: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
    #         severity: '{{ .CommonLabels.severity }}'
    #
    #   - name: 'pagerduty-database-cluster'
    #     pagerduty_configs:
    #       - routing_key: '${try(module.pagerduty_complete.pd_int["database-cluster"].pagerduty_key, "INTEGRATION_KEY_HERE")}'
    #         description: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
    #         severity: '{{ .CommonLabels.severity }}'
  EOT
}