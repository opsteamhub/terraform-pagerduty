resource "pagerduty_service" "service" {
  for_each                = var.services
  name                    = each.key
  auto_resolve_timeout    = each.value["auto_resolve_timeout"]
  acknowledgement_timeout = each.value["acknowledgement_timeout"]
  escalation_policy       = pagerduty_escalation_policy.es_policy[each.key].id
  alert_creation          = each.value["alert_creation"]

  depends_on = [
    pagerduty_escalation_policy.es_policy
  ]

}

resource "pagerduty_escalation_policy" "es_policy" {
  for_each = var.services
  name     = join("-", [each.key, "pl"])
  teams    = [data.pagerduty_team.team[each.key].id]

  depends_on = [
    pagerduty_team.team,
    pagerduty_schedule.schedule,
    pagerduty_user.user
  ]

  dynamic "rule" {
    for_each = each.value["rules"]
    content {
      escalation_delay_in_minutes = rule.value["escalation_delay_in_minutes"]

      target {
        type = rule.value["type"]
        #id = data.pagerduty_schedule.schedule[each.key].id
        id = rule.value["type"] == "schedule_reference" ? pagerduty_schedule.schedule[rule.value["target"]].id : pagerduty_user.user[rule.value["target"]].id
      }
    }
  }
}

data "pagerduty_team" "team" {
  for_each = var.services
  name     = each.value["teams"]

  depends_on = [
    pagerduty_team.team
  ]
}

data "pagerduty_user" "users" {
  for_each = var.schedule
  email    = each.value["users"]

  depends_on = [
    pagerduty_user.user
  ]
}

#data "pagerduty_schedule" "schedule" {
#  for_each = var.services
#  name = "Scale Weekdays Rotation"
#
#  depends_on = [
#    pagerduty_schedule.schedule
#  ]
#}

