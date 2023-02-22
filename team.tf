resource "pagerduty_team" "team" {
  for_each = var.teams

  name        = each.key
  description = each.value["team_description"]
}