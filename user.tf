locals {
  team_membership = flatten([
    for user, user_attr in var.users : [
      for team in user_attr.teams_member : {
        user = user
        team = team
      }
    ]
  ])
}


resource "pagerduty_user" "user" {
  for_each = var.users

  name      = each.value["user_name"]
  email     = each.key
  role      = each.value["user_role"]
  time_zone = each.value["user_time_zone"]
}


resource "pagerduty_team_membership" "member" {
  for_each = { for pair in local.team_membership :
    "${pair.user}.${pair.team}" => pair
  }

  user_id = pagerduty_user.user[each.value.user].id
  team_id = pagerduty_team.team[each.value.team].id

  depends_on = [
    pagerduty_team.team
  ]
}

resource "pagerduty_user_contact_method" "phone" {
  for_each     = var.users
  user_id      = pagerduty_user.user[each.key].id
  type         = "phone_contact_method"
  country_code = each.value["country_code"]
  address      = each.value["phone"]
  label        = each.value["label"]
}

resource "pagerduty_user_contact_method" "sms" {
  for_each     = var.users
  user_id      = pagerduty_user.user[each.key].id
  type         = "sms_contact_method"
  country_code = each.value["country_code"]
  address      = each.value["phone"]
  label        = each.value["label"]
}


resource "pagerduty_user_notification_rule" "high_urgency_phone" {
  for_each               = var.users
  user_id                = pagerduty_user.user[each.key].id
  start_delay_in_minutes = 1
  urgency                = "high"

  contact_method = {
    type = "phone_contact_method"
    id   = pagerduty_user_contact_method.phone[each.key].id
  }
}

resource "pagerduty_user_notification_rule" "high_urgency_sms" {
  for_each               = var.users
  user_id                = pagerduty_user.user[each.key].id
  start_delay_in_minutes = 0
  urgency                = "high"

  contact_method = {
    type = "sms_contact_method"
    id   = pagerduty_user_contact_method.sms[each.key].id
  }
}