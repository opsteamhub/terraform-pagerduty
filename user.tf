#locals {
#  team_membership = flatten([
#    for user, user_attr in var.users : [
#      for team in user_attr.teams_member : {
#        user = user
#        team = team
#      }
#    ]
#  ])
#}


resource "pagerduty_user" "user" {
  for_each = var.users

  name      = each.value["user_name"]
  email     = each.key
  role      = each.value["user_role"]
  time_zone = each.value["user_time_zone"]
}

#
#resource "pagerduty_team_membership" "member" {
#  for_each = { for pair in local.team_membership :
#    "${pair.user}.${pair.team}" => pair
#  }
#
#  user_id = pagerduty_user.user[each.value.user].id
#  team_id = pagerduty_team.team[each.value.team].id
#
#  depends_on = [
#    pagerduty_team.team
#  ]
#}

resource "pagerduty_user_contact_method" "phone" {
  for_each     = var.users
  user_id      = pagerduty_user.user[each.key].id
  type         = "phone_contact_method"
  country_code = each.value["country_code"]
  address      = each.value["phone"]
  label        = each.value["label"]
}

locals {
  # O WhatsApp pode ficar em um número diferente do de voz. Sem whatsapp_phone,
  # o comportamento continua o de antes: mesmo número do phone_contact_method.
  whatsapp = { for email, user in var.users : email => {
    country_code = user.whatsapp_country_code != "" ? user.whatsapp_country_code : user.country_code
    phone        = user.whatsapp_phone != "" ? user.whatsapp_phone : user.phone
    label        = user.whatsapp_label != "" ? user.whatsapp_label : user.label
  } }
}

resource "pagerduty_user_contact_method" "sms" {
  for_each     = var.users
  user_id      = pagerduty_user.user[each.key].id
  type         = "whatsapp_contact_method"
  country_code = local.whatsapp[each.key].country_code
  address      = local.whatsapp[each.key].phone
  label        = local.whatsapp[each.key].label
}

resource "pagerduty_user_notification_rule" "high_urgency_phone" {
  for_each               = var.users
  user_id                = pagerduty_user.user[each.key].id
  start_delay_in_minutes = 3
  urgency                = "high"

  contact_method {
    type = "phone_contact_method"
    id   = pagerduty_user_contact_method.phone[each.key].id
  }
}

resource "pagerduty_user_notification_rule" "high_urgency_sms" {
  for_each               = var.users
  user_id                = pagerduty_user.user[each.key].id
  start_delay_in_minutes = 3
  urgency                = "high"

  contact_method {
    # O contact method referenciado aqui é do tipo whatsapp_contact_method, mas
    # este campo precisa continuar "sms_contact_method": o provider só valida
    # email/phone/push/sms nas notification rules e o PagerDuty trata WhatsApp
    # como da mesma família de SMS. Trocar por whatsapp_contact_method faz o
    # plan falhar com "Invalid Attribute Value Match".
    type = "sms_contact_method"
    id   = pagerduty_user_contact_method.sms[each.key].id
  }
}

