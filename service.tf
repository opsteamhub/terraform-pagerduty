resource "pagerduty_service" "service" {
  for_each                = var.services
  name                    = each.key
  description             = each.value["description"]
  auto_resolve_timeout    = each.value["auto_resolve_timeout"]
  acknowledgement_timeout = each.value["acknowledgement_timeout"]
  escalation_policy       = pagerduty_escalation_policy.es_policy[each.key].id
  alert_creation          = each.value["alert_creation"]

  depends_on = [
    pagerduty_escalation_policy.es_policy,
    pagerduty_schedule.schedule
  ]

  incident_urgency_rule {
    type    = "constant"
    urgency = "severity_based"


  }



}

resource "pagerduty_escalation_policy" "es_policy" {
  for_each = var.services

  name = join("-", [each.key, "pl"])

  depends_on = [
    pagerduty_schedule.schedule,
    pagerduty_user.user
  ]

  dynamic "rule" {
    for_each = {
      for r in each.value.rules : r.name => r
    }
    content {
      escalation_delay_in_minutes = rule.value.escalation_delay_in_minutes

      dynamic "target" {
        for_each = rule.value.targets
        content {
          type = target.value.type
          id = (
            target.value.type == "user_reference"
            ? lookup(pagerduty_user.user, target.value.target).id
            : lookup(pagerduty_schedule.schedule, target.value.target).id
          )
        }
      }
    }
  }
}



