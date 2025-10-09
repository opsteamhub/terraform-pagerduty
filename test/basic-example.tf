# Basic PagerDuty Configuration Example
# This example demonstrates a minimal setup with one service, user, and schedule

terraform {
  required_providers {
    pagerduty = {
      source  = "pagerduty/pagerduty"
      version = "3.23.1"
    }
  }
}

# Variables for authentication
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

# Basic PagerDuty module usage
module "pagerduty_basic" {
  source = "../"

  pagerduty_token      = var.pagerduty_token
  pagerduty_user_token = var.pagerduty_user_token

  # Single service configuration
  services = {
    "web-application" = {
      description             = "Web Application Service"
      auto_resolve_timeout    = 14400  # 4 hours
      acknowledgement_timeout = 600    # 10 minutes
      alert_creation          = "create_alerts_and_incidents"
      
      rules = [
        {
          name                        = "Primary Escalation"
          escalation_delay_in_minutes = 15
          targets = [
            {
              type   = "schedule_reference"
              target = "basic-schedule"
            }
          ]
        }
      ]
    }
  }

  # Single user configuration
  users = {
    "admin@company.com" = {
      user_name      = "System Administrator"
      user_email     = "admin@company.com"
      user_role      = "admin"
      user_time_zone = "America/New_York"
      country_code   = "+1"
      phone          = "5551234567"
      label          = "Work"
    }
  }

  # Basic schedule configuration
  schedule = {
    "basic-schedule" = {
      name      = "Basic On-Call Schedule"
      time_zone = "America/New_York"
      
      layers = [
        {
          name                         = "Primary Layer"
          start                        = "2024-01-01T08:00:00Z"
          rotation_virtual_start       = "2024-01-01T08:00:00Z"
          rotation_turn_length_seconds = 604800  # 1 week rotation
          
          users = {
            "admin" = "admin@company.com"
          }
        }
      ]
    }
  }
}

# Output the integration key for Prometheus configuration
output "prometheus_integration_key" {
  description = "Integration key for Prometheus Alertmanager"
  value       = module.pagerduty_basic.pd_int
  sensitive   = true
}