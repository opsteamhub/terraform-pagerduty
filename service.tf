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
    type = "constant"
    urgency = "severity_based"


  }



}

resource "pagerduty_escalation_policy" "es_policy" {
  for_each = var.services
  name     = join("-", [each.key, "pl"])
  #teams    = [data.pagerduty_team.team[each.key].id]

  depends_on = [
    #pagerduty_team.team,
    pagerduty_schedule.schedule,
    pagerduty_user.user
  ]

  dynamic "rule" {
    for_each = each.value["rules"]
    content {
      escalation_delay_in_minutes = rule.value["escalation_delay_in_minutes"]

      dynamic "target" {
        for_each = rule.value["target"]
        content {
          type = rule.value["type"]
          id = try(
            pagerduty_schedule.schedule[target.value].id,
            pagerduty_user.user[target.value].id
          )
        }
      }

      ##target {
      ##  type = rule.value["type"]
      ##  id   = rule.value["type"] == "schedule_reference" ? [ for x in rule.value["target"]: 
      ##    pagerduty_schedule.schedule[x].id 
      ##  ] : [ for x in rule.value["target"]:
      ##    pagerduty_user.user[x].id
      ##  ]
      ##  #id = rule.value["type"] == "schedule_reference" ? pagerduty_schedule.schedule[rule.value["target"]].id : pagerduty_user.user[rule.value["target"]].id
      ##}
    }
  }
}

#data "pagerduty_team" "team" {
#  for_each = var.services
#  name     = each.value["teams"]
#
#  depends_on = [
#    pagerduty_team.team
#  ]
#}

#data "pagerduty_user" "users" {
#  for_each = var.schedule
#  email    = each.value["users"]
#
#  depends_on = [
#    pagerduty_user.user
#  ]
#}

#data "pagerduty_schedule" "schedule" {
#  for_each = var.services
#  name = "Scale Weekdays Rotation"
#
#  depends_on = [
#    pagerduty_schedule.schedule
#  ]
#}

