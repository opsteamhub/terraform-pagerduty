# Terraform PagerDuty Module

A comprehensive Terraform module for managing PagerDuty resources including services, users, schedules, escalation policies, and integrations.

## Features

- **Service Management**: Create and configure PagerDuty services with custom escalation policies
- **User Management**: Provision users with contact methods and notification rules
- **Schedule Management**: Set up on-call schedules with rotation and restrictions
- **Integrations**: Support for Prometheus and Slack integrations
- **Escalation Policies**: Automated escalation rules with customizable delays
- **Contact Methods**: Phone and SMS notifications with urgency-based rules

## Usage

```hcl
module "pagerduty" {
  source = "./terraform-pagerduty"

  pagerduty_token      = var.pagerduty_token
  pagerduty_user_token = var.pagerduty_user_token

  services = {
    "production-api" = {
      description             = "Production API Service"
      auto_resolve_timeout    = 14400
      acknowledgement_timeout = 600
      alert_creation          = "create_alerts_and_incidents"
      
      rules = [
        {
          name                        = "Primary Escalation"
          escalation_delay_in_minutes = 15
          targets = [
            {
              type   = "schedule_reference"
              target = "primary-schedule"
            }
          ]
        }
      ]
      
      slack_integration          = true
      workspace_id              = "T1234567890"
      channel_id                = "C1234567890"
      service_integration       = true
      service_integration_vendor = "Prometheus"
    }
  }

  users = {
    "john.doe@company.com" = {
      user_name      = "John Doe"
      user_email     = "john.doe@company.com"
      user_role      = "user"
      user_time_zone = "America/New_York"
      country_code   = "+1"
      phone          = "5551234567"
      label          = "Work"
    }
  }

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
            "user1" = "john.doe@company.com"
            "user2" = "jane.smith@company.com"
          }
          
          restriction = [
            {
              create_restriction = true
              type              = "weekly_restriction"
              start_time_of_day = "08:00:00"
              duration_seconds  = 36000  # 10 hours
              start_day_of_week = 1      # Monday
            }
          ]
        }
      ]
    }
  }
}
```

## Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `pagerduty_token` | PagerDuty API token | `string` |
| `pagerduty_user_token` | PagerDuty user token for user management | `string` |

### Optional Variables

#### Services Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `services` | Map of services to create | `map(object)` | `{}` |

**Service Object Structure:**
- `name` - Service name (optional, uses key if not provided)
- `description` - Service description (default: "Provisioning Service by Terraform")
- `auto_resolve_timeout` - Auto-resolve timeout in seconds (default: 14400)
- `acknowledgement_timeout` - Acknowledgement timeout in seconds (default: 600)
- `alert_creation` - Alert creation mode (default: "create_alerts_and_incidents")
- `rules` - List of escalation rules
- `slack_integration` - Enable Slack integration (default: false)
- `service_integration` - Enable service integration (default: false)
- `service_integration_vendor` - Integration vendor (default: "Prometheus")

#### Users Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `users` | Map of users to create | `map(object)` | `{}` |

**User Object Structure:**
- `user_name` - User's full name
- `user_email` - User's email address
- `user_role` - User role (default: "user")
- `user_time_zone` - User's timezone (default: "America/Sao_Paulo")
- `country_code` - Phone country code (default: "+55")
- `phone` - Phone number
- `label` - Contact method label (default: "Work")

#### Schedule Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `schedule` | Map of schedules to create | `map(object)` | `{}` |
| `update_schedule` | Whether to update existing schedules | `bool` | `true` |

**Schedule Object Structure:**
- `name` - Schedule name
- `time_zone` - Schedule timezone (default: "America/Sao_Paulo")
- `layers` - List of schedule layers with rotation and restriction settings

## Outputs

| Name | Description |
|------|-------------|
| `pd_int` | Map of service integrations with keys and names |
| `service_integration` | Complete service integration objects |

## Resources Created

### Core Resources
- `pagerduty_service` - PagerDuty services
- `pagerduty_escalation_policy` - Escalation policies for services
- `pagerduty_user` - User accounts
- `pagerduty_schedule` - On-call schedules

### Contact Methods
- `pagerduty_user_contact_method` - Phone and SMS contact methods
- `pagerduty_user_notification_rule` - Notification rules for different urgencies

### Integrations
- `pagerduty_service_integration` - Service integrations (Prometheus, etc.)
- `pagerduty_slack_connection` - Slack workspace integrations

## Integration Examples

### Prometheus Integration
When `service_integration = true` and `service_integration_vendor = "Prometheus"`, the module creates a Prometheus integration and outputs the integration key for use in Prometheus Alertmanager configuration.

### Slack Integration
When `slack_integration = true`, the module creates a Slack connection that sends notifications for various incident events to the specified Slack channel.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| pagerduty | 3.23.1 |
| helm | >= 2.1 |

## Providers

| Name | Version |
|------|---------|
| pagerduty | 3.23.1 |

## Notes

- Users must exist before they can be assigned to schedules
- Services depend on escalation policies and schedules
- Contact methods are automatically created for all users
- High urgency notifications are configured for both phone and SMS after 3 minutes
- Weekly restrictions can be applied to schedule layers for business hours coverage

## License

This module is provided as-is for internal use within OpsTeam infrastructure management.