### PagerDuty Terraform Module

The object of module is create and manager users, services and schedules in PagerDuty.
https://www.pagerduty.com/

##### Calling module
```
variable "services" {}
variable "teams" {}
variable "users" {}
variable "schedule" {}

module "pagerduty" {
  source = "github.com/opsteamhub/terraform-pagerduty"

  services = var.services
  teams    = var.teams
  users    = var.users
  schedule = var.schedule
}
```

##### Create Teams and Users
```
teams = {
  monitoring = {
    team_description = "Observability team."
  }
  N2 = {
    team_description = "Nivel 2"
  }
  manager = {
    team_description = "Manager Team"
  }
}

users = {
  "rafael.julio@ops.team" = {
    user_name    = "Rafael Júlio"
    teams_member = ["N2"]
    phone        = "319999999"
  },
  "bruno.paiuca@ops.team" = {
    user_name    = "Bruno Paiuca"
    teams_member = ["manager"]
    phone        = "1199999999"
  }
}
```
##### Create Services and Schedules
```
schedule = {
  weekdays = {
    name  = "Scale Weekdays Rotation"
    users = "bruno.paiuca@ops.team"
    start = "2023-02-15T08:00:00Z"
  }
}

services = {
  elasticsearch = {
    teams                      = "monitoring"
    slack_integration          = true # Enable slack integration
    workspace_id               = "T024XXXXX" # slack workspaceID
    channel_id                 = "C0XXXXXXX" # slack channelID
    service_integration        = true # Enable APP integration
    service_integration_vendor = "Prometheus" # APP Integration Name
    rules = {
      N1 = {
        escalation_delay_in_minutes = 10
        type                        = "schedule_reference"
        target                      = "weekdays"
      },
      N2 = {
        escalation_delay_in_minutes = 15
        type                        = "user_reference"
        target                      = "rafael.julio@ops.team"
      }
    }
  },
  kubernetes = {
    teams                      = "monitoring"
    slack_integration          = true # Enable slack integration
    workspace_id               = "T024XXXXXXX" # slack workspaceID
    channel_id                 = "C0XXXXXXXXX" # slack channelID
    service_integration        = true # Enable APP integration
    service_integration_vendor = "Prometheus" # APP Integration Name
    rules = {
      N1 = {
        escalation_delay_in_minutes = 10
        type                        = "schedule_reference"
        target                      = "weekdays"
      },
      N2 = {
        escalation_delay_in_minutes = 15
        type                        = "user_reference"
        target                      = "rafael.julio@ops.team"
      }
    }
  }  
}
```
