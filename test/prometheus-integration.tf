# Prometheus Integration Example
# This example focuses on setting up PagerDuty services specifically for Prometheus monitoring

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

# PagerDuty configuration optimized for Prometheus monitoring
module "pagerduty_prometheus" {
  source = "../"

  pagerduty_token      = var.pagerduty_token
  pagerduty_user_token = var.pagerduty_user_token

  # Services configured for different severity levels
  services = {
    "critical-alerts" = {
      description             = "Critical Production Alerts from Prometheus"
      auto_resolve_timeout    = 3600   # 1 hour - critical issues should be resolved quickly
      acknowledgement_timeout = 180    # 3 minutes - fast acknowledgement required
      alert_creation          = "create_alerts_and_incidents"
      
      rules = [
        {
          name                        = "Immediate Response"
          escalation_delay_in_minutes = 5
          targets = [
            {
              type   = "schedule_reference"
              target = "sre-primary"
            }
          ]
        },
        {
          name                        = "Management Escalation"
          escalation_delay_in_minutes = 15
          targets = [
            {
              type   = "user_reference"
              target = "sre-manager@company.com"
            }
          ]
        }
      ]
      
      service_integration       = true
      service_integration_vendor = "Prometheus"
    }

    "warning-alerts" = {
      description             = "Warning Level Alerts from Prometheus"
      auto_resolve_timeout    = 7200   # 2 hours
      acknowledgement_timeout = 600    # 10 minutes
      alert_creation          = "create_alerts_and_incidents"
      
      rules = [
        {
          name                        = "SRE Team Response"
          escalation_delay_in_minutes = 30
          targets = [
            {
              type   = "schedule_reference"
              target = "sre-secondary"
            }
          ]
        }
      ]
      
      service_integration       = true
      service_integration_vendor = "Prometheus"
    }

    "infrastructure-monitoring" = {
      description             = "Infrastructure Monitoring Alerts"
      auto_resolve_timeout    = 14400  # 4 hours
      acknowledgement_timeout = 900    # 15 minutes
      alert_creation          = "create_alerts_and_incidents"
      
      rules = [
        {
          name                        = "Infrastructure Team"
          escalation_delay_in_minutes = 20
          targets = [
            {
              type   = "user_reference"
              target = "infra-lead@company.com"
            }
          ]
        }
      ]
      
      service_integration       = true
      service_integration_vendor = "Prometheus"
    }
  }

  # SRE team members
  users = {
    "sre-manager@company.com" = {
      user_name      = "SRE Manager"
      user_email     = "sre-manager@company.com"
      user_role      = "manager"
      user_time_zone = "America/New_York"
      country_code   = "+1"
      phone          = "5551111111"
      label          = "Work"
    }

    "sre-engineer1@company.com" = {
      user_name      = "Senior SRE Engineer"
      user_email     = "sre-engineer1@company.com"
      user_role      = "user"
      user_time_zone = "America/New_York"
      country_code   = "+1"
      phone          = "5552222222"
      label          = "Work"
    }

    "sre-engineer2@company.com" = {
      user_name      = "SRE Engineer"
      user_email     = "sre-engineer2@company.com"
      user_role      = "user"
      user_time_zone = "America/Los_Angeles"
      country_code   = "+1"
      phone          = "5553333333"
      label          = "Work"
    }

    "infra-lead@company.com" = {
      user_name      = "Infrastructure Lead"
      user_email     = "infra-lead@company.com"
      user_role      = "user"
      user_time_zone = "Europe/London"
      country_code   = "+44"
      phone          = "7700444444"
      label          = "Work"
    }
  }

  # Schedules optimized for 24/7 coverage
  schedule = {
    "sre-primary" = {
      name      = "SRE Primary On-Call"
      time_zone = "UTC"
      
      layers = [
        {
          name                         = "Primary SRE Layer"
          start                        = "2024-01-01T00:00:00Z"
          rotation_virtual_start       = "2024-01-01T00:00:00Z"
          rotation_turn_length_seconds = 604800  # 1 week rotation
          
          users = {
            "sre1" = "sre-engineer1@company.com"
            "sre2" = "sre-engineer2@company.com"
          }
        }
      ]
    }

    "sre-secondary" = {
      name      = "SRE Secondary On-Call"
      time_zone = "UTC"
      
      layers = [
        {
          name                         = "Secondary SRE Layer"
          start                        = "2024-01-01T00:00:00Z"
          rotation_virtual_start       = "2024-01-01T00:00:00Z"
          rotation_turn_length_seconds = 1209600  # 2 week rotation
          
          users = {
            "sre_secondary" = "sre-manager@company.com"
            "infra_backup"  = "infra-lead@company.com"
          }
        }
      ]
    }
  }
}

# Output integration keys for Prometheus Alertmanager configuration
output "prometheus_integration_keys" {
  description = "Integration keys for each service - use these in Prometheus Alertmanager"
  value = {
    critical_alerts_key      = module.pagerduty_prometheus.pd_int["critical-alerts"].pagerduty_key
    warning_alerts_key       = module.pagerduty_prometheus.pd_int["warning-alerts"].pagerduty_key
    infrastructure_monitoring_key = module.pagerduty_prometheus.pd_int["infrastructure-monitoring"].pagerduty_key
  }
  sensitive = true
}

# Generate Prometheus Alertmanager configuration
output "alertmanager_config" {
  description = "Complete Alertmanager configuration for PagerDuty integration"
  value = <<-EOT
# Prometheus Alertmanager Configuration
# Add this to your alertmanager.yml file

global:
  pagerduty_url: 'https://events.pagerduty.com/v2/enqueue'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'
  routes:
  - match:
      severity: critical
    receiver: pagerduty-critical
  - match:
      severity: warning
    receiver: pagerduty-warning
  - match:
      alertname: ~".*infrastructure.*|.*node.*|.*disk.*|.*memory.*"
    receiver: pagerduty-infrastructure

receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://127.0.0.1:5001/'

- name: 'pagerduty-critical'
  pagerduty_configs:
  - routing_key: '${module.pagerduty_prometheus.pd_int["critical-alerts"].pagerduty_key}'
    description: 'CRITICAL: {{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
    severity: 'critical'
    details:
      firing: '{{ .Alerts.Firing | len }}'
      resolved: '{{ .Alerts.Resolved | len }}'
      alertname: '{{ .CommonLabels.alertname }}'
      instance: '{{ .CommonLabels.instance }}'

- name: 'pagerduty-warning'
  pagerduty_configs:
  - routing_key: '${module.pagerduty_prometheus.pd_int["warning-alerts"].pagerduty_key}'
    description: 'WARNING: {{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
    severity: 'warning'
    details:
      firing: '{{ .Alerts.Firing | len }}'
      resolved: '{{ .Alerts.Resolved | len }}'
      alertname: '{{ .CommonLabels.alertname }}'
      instance: '{{ .CommonLabels.instance }}'

- name: 'pagerduty-infrastructure'
  pagerduty_configs:
  - routing_key: '${module.pagerduty_prometheus.pd_int["infrastructure-monitoring"].pagerduty_key}'
    description: 'INFRA: {{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
    severity: 'warning'
    details:
      firing: '{{ .Alerts.Firing | len }}'
      resolved: '{{ .Alerts.Resolved | len }}'
      alertname: '{{ .CommonLabels.alertname }}'
      instance: '{{ .CommonLabels.instance }}'

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
  EOT
}