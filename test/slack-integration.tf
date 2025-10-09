# Slack Integration Example
# This example demonstrates how to set up PagerDuty services with Slack notifications

terraform {
  required_providers {
    pagerduty = {
      source  = "pagerduty/pagerduty"
      version = "3.23.1"
    }
  }
}

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

# Slack workspace and channel configuration
variable "slack_workspace_id" {
  description = "Slack workspace ID (found in Slack app settings)"
  type        = string
  default     = "T1234567890"  # Replace with your actual workspace ID
}

variable "alerts_channel_id" {
  description = "Slack channel ID for critical alerts"
  type        = string
  default     = "C1111111111"  # Replace with your actual channel ID
}

variable "warnings_channel_id" {
  description = "Slack channel ID for warning alerts"
  type        = string
  default     = "C2222222222"  # Replace with your actual channel ID
}

variable "general_channel_id" {
  description = "Slack channel ID for general notifications"
  type        = string
  default     = "C3333333333"  # Replace with your actual channel ID
}

# PagerDuty configuration with Slack integrations
module "pagerduty_slack" {
  source = "../"

  pagerduty_token      = var.pagerduty_token
  pagerduty_user_token = var.pagerduty_user_token

  # Services with different Slack notification channels
  services = {
    "production-critical" = {
      description             = "Production Critical Services"
      auto_resolve_timeout    = 3600   # 1 hour
      acknowledgement_timeout = 300    # 5 minutes
      alert_creation          = "create_alerts_and_incidents"
      
      rules = [
        {
          name                        = "Immediate Response Team"
          escalation_delay_in_minutes = 5
          targets = [
            {
              type   = "schedule_reference"
              target = "critical-response"
            }
          ]
        },
        {
          name                        = "Management Escalation"
          escalation_delay_in_minutes = 15
          targets = [
            {
              type   = "user_reference"
              target = "manager@company.com"
            }
          ]
        }
      ]
      
      # Slack integration for critical alerts
      slack_integration  = true
      workspace_id      = var.slack_workspace_id
      channel_id        = var.alerts_channel_id
      notification_type = "responder"
      source_type       = "service_reference"
    }

    "application-warnings" = {
      description             = "Application Warning Level Alerts"
      auto_resolve_timeout    = 7200   # 2 hours
      acknowledgement_timeout = 900    # 15 minutes
      alert_creation          = "create_alerts_and_incidents"
      
      rules = [
        {
          name                        = "Development Team"
          escalation_delay_in_minutes = 30
          targets = [
            {
              type   = "schedule_reference"
              target = "dev-team-schedule"
            }
          ]
        }
      ]
      
      # Slack integration for warnings
      slack_integration  = true
      workspace_id      = var.slack_workspace_id
      channel_id        = var.warnings_channel_id
      notification_type = "responder"
      source_type       = "service_reference"
    }

    "infrastructure-monitoring" = {
      description             = "Infrastructure and System Monitoring"
      auto_resolve_timeout    = 14400  # 4 hours
      acknowledgement_timeout = 1800   # 30 minutes
      alert_creation          = "create_alerts_and_incidents"
      
      rules = [
        {
          name                        = "Infrastructure Team"
          escalation_delay_in_minutes = 45
          targets = [
            {
              type   = "user_reference"
              target = "infra-lead@company.com"
            }
          ]
        }
      ]
      
      # Slack integration for infrastructure alerts
      slack_integration  = true
      workspace_id      = var.slack_workspace_id
      channel_id        = var.general_channel_id
      notification_type = "responder"
      source_type       = "service_reference"
    }

    # Service without Slack integration for comparison
    "internal-tools" = {
      description             = "Internal Tools and Utilities"
      auto_resolve_timeout    = 28800  # 8 hours
      acknowledgement_timeout = 3600   # 1 hour
      alert_creation          = "create_alerts_and_incidents"
      
      rules = [
        {
          name                        = "Tools Team"
          escalation_delay_in_minutes = 60
          targets = [
            {
              type   = "user_reference"
              target = "tools-admin@company.com"
            }
          ]
        }
      ]
      
      # No Slack integration - only PagerDuty notifications
      slack_integration = false
    }
  }

  # Team members for different response levels
  users = {
    "manager@company.com" = {
      user_name      = "Engineering Manager"
      user_email     = "manager@company.com"
      user_role      = "manager"
      user_time_zone = "America/New_York"
      country_code   = "+1"
      phone          = "5551111111"
      label          = "Work"
    }

    "oncall-engineer1@company.com" = {
      user_name      = "Senior On-Call Engineer"
      user_email     = "oncall-engineer1@company.com"
      user_role      = "user"
      user_time_zone = "America/New_York"
      country_code   = "+1"
      phone          = "5552222222"
      label          = "Work"
    }

    "oncall-engineer2@company.com" = {
      user_name      = "On-Call Engineer"
      user_email     = "oncall-engineer2@company.com"
      user_role      = "user"
      user_time_zone = "America/Los_Angeles"
      country_code   = "+1"
      phone          = "5553333333"
      label          = "Work"
    }

    "dev-lead@company.com" = {
      user_name      = "Development Team Lead"
      user_email     = "dev-lead@company.com"
      user_role      = "user"
      user_time_zone = "America/Chicago"
      country_code   = "+1"
      phone          = "5554444444"
      label          = "Work"
    }

    "infra-lead@company.com" = {
      user_name      = "Infrastructure Lead"
      user_email     = "infra-lead@company.com"
      user_role      = "user"
      user_time_zone = "Europe/London"
      country_code   = "+44"
      phone          = "7700555555"
      label          = "Work"
    }

    "tools-admin@company.com" = {
      user_name      = "Tools Administrator"
      user_email     = "tools-admin@company.com"
      user_role      = "user"
      user_time_zone = "America/Denver"
      country_code   = "+1"
      phone          = "5556666666"
      label          = "Work"
    }
  }

  # Schedules for different response teams
  schedule = {
    "critical-response" = {
      name      = "Critical Response Team Schedule"
      time_zone = "America/New_York"
      
      layers = [
        {
          name                         = "Primary Critical Response"
          start                        = "2024-01-01T00:00:00Z"
          rotation_virtual_start       = "2024-01-01T00:00:00Z"
          rotation_turn_length_seconds = 604800  # 1 week
          
          users = {
            "primary1" = "oncall-engineer1@company.com"
            "primary2" = "oncall-engineer2@company.com"
          }
        }
      ]
    }

    "dev-team-schedule" = {
      name      = "Development Team Schedule"
      time_zone = "America/Chicago"
      
      layers = [
        {
          name                         = "Development Team Layer"
          start                        = "2024-01-01T08:00:00Z"
          rotation_virtual_start       = "2024-01-01T08:00:00Z"
          rotation_turn_length_seconds = 1209600  # 2 weeks
          
          users = {
            "dev_lead" = "dev-lead@company.com"
            "manager"  = "manager@company.com"
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
  }
}

# Output information about Slack integrations
output "slack_integration_summary" {
  description = "Summary of Slack integrations configured"
  value = {
    production_critical = {
      service_name = "production-critical"
      slack_channel = var.alerts_channel_id
      workspace = var.slack_workspace_id
    }
    application_warnings = {
      service_name = "application-warnings"
      slack_channel = var.warnings_channel_id
      workspace = var.slack_workspace_id
    }
    infrastructure_monitoring = {
      service_name = "infrastructure-monitoring"
      slack_channel = var.general_channel_id
      workspace = var.slack_workspace_id
    }
  }
}

# Instructions for Slack setup
output "slack_setup_instructions" {
  description = "Instructions for completing Slack integration setup"
  value = <<-EOT
    Slack Integration Setup Instructions:
    
    1. Install the PagerDuty app in your Slack workspace
    2. Get your Slack workspace ID from: https://api.slack.com/methods/auth.test
    3. Get channel IDs by right-clicking on channels and selecting "Copy link"
    4. Update the variables in this configuration:
       - slack_workspace_id: ${var.slack_workspace_id}
       - alerts_channel_id: ${var.alerts_channel_id}
       - warnings_channel_id: ${var.warnings_channel_id}
       - general_channel_id: ${var.general_channel_id}
    
    5. The following events will be sent to Slack:
       - incident.triggered
       - incident.acknowledged
       - incident.escalated
       - incident.resolved
       - incident.reassigned
       - incident.annotated
       - incident.unacknowledged
       - incident.delegated
       - incident.priority_updated
       - incident.responder.added
       - incident.responder.replied
       - incident.status_update_published
       - incident.reopened
    
    6. Services with Slack integration:
       - production-critical → #alerts channel
       - application-warnings → #warnings channel
       - infrastructure-monitoring → #general channel
       - internal-tools → No Slack integration (PagerDuty only)
  EOT
}