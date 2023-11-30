variable "pagerduty_token" {}

variable "pagerduty_user_token" {}

variable "services" {
  type = map(object({
    name                    = optional(string)
    description             = optional(string, "Provisioning Service by Terraform")
    auto_resolve_timeout    = optional(number, 14400)
    acknowledgement_timeout = optional(number, 600)
    alert_creation          = optional(string, "create_alerts_and_incidents")
    #teams                   = optional(string, null)

    rules = optional(map(object({
      escalation_delay_in_minutes = optional(number, 15)
      type                        = optional(string, "schedule_reference")
      target                      = optional(set(string), null)
    })))
    source_type                = optional(string, "service_reference")
    workspace_id               = optional(string, "")
    channel_id                 = optional(string, "")
    notification_type          = optional(string, "responder")
    priority_name              = optional(string, "*")
    slack_integration          = optional(bool, false)
    service_integration        = optional(bool, false)
    service_integration_vendor = optional(string, "Prometheus")
  }))
  default = {}
}

#variable "teams" {
#  type = map(object({
#    team_name        = optional(string)
#    team_description = optional(string)
#  }))
#  default = {}
#}

variable "users" {
  type = map(object({
    user_name      = optional(string, "")
    user_email     = optional(string, "")
    user_role      = optional(string, "user")
    user_time_zone = optional(string, "America/Sao_Paulo")
    #teams_member   = list(string)
    country_code = optional(string, "+55")
    phone        = optional(string, "")
    label        = optional(string, "Work")
  }))
  default = {}
}

variable "schedule" {
  type = map(object({
    name                           = optional(string)
    time_zone                      = optional(string, "Etc/UTC")
    #layer_name                     = optional(string)
    #start                          = optional(string, "2023-02-16T08:00:00Z")
    #rotation_virtual_start         = optional(string, "2023-02-16T08:00:00Z")
    #rotation_turn_length_seconds   = optional(number, 86400)
    #users                          = optional(list(string), [])
    type                           = optional(string, "weekly_restriction")
    start_time_of_day              = optional(string, "16:00:00")
    duration_seconds               = optional(number, 432000)
    start_day_of_week              = optional(number, 7)
    layer                          = optional(list(object({
      name                         = optional(string)
      start                        = optional(string, "2023-02-16T08:00:00Z")
      rotation_virtual_start       = optional(string, "2023-02-16T08:00:00Z")
      rotation_turn_length_seconds = optional(number, 86400)
      users                        = optional(set(string), null)
    })))
  }))
  default = {}
}


