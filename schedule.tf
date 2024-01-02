resource "pagerduty_schedule" "schedule" {
  for_each  = var.schedule
  name      = each.value["name"]
  time_zone = each.value["time_zone"]

  depends_on = [
    pagerduty_user.user
  ]
  dynamic "layer" {
    for_each = each.value["layers"]
    content {
      name                         = layer.value["name"]
      start                        = layer.value["start"]
      rotation_virtual_start       = layer.value["rotation_virtual_start"]
      rotation_turn_length_seconds = layer.value["rotation_turn_length_seconds"]
      #users = [ for x in layer.value["users"] :
      #  data.pagerduty_user.users[x].id
      #]
      users = [for x in layer.value["users"] : data.pagerduty_user.users[x].id]

    dynamic "restriction" {
      for_each = { for k, v in layer.value["restriction"] :
        k => v if try(v["create_restriction"], false) == true
      }  
      content {
        type              = restriction.value["type"] 
        start_time_of_day = restriction.value["start_time_of_day"]
        duration_seconds  = restriction.value["duration_seconds"]
        start_day_of_week = restriction.value["type"]  == "weekly_restriction" ? restriction.value["start_day_of_week"] : null
      }  
    }

   }
  }
}

#data "pagerduty_user" "users" {
#  for_each = zipmap(
#    flatten(distinct(flatten(values(var.schedule)[*]["layers"])[*]["users"])),
#    flatten(distinct(flatten(values(var.schedule)[*]["layers"])[*]["users"]))
#  )
#  email = each.value
#
#
#  depends_on = [
#    pagerduty_user.user
#  ]
#}

data "pagerduty_user" "users" {
  for_each = toset(flatten([
    for schedule_key, schedule_data in var.schedule : [
      for layer_key, layer_data in schedule_data.layers : [
        for user_email in values(layer_data.users) : user_email
      ]
    ]
  ]))

  email = each.value

  depends_on = [
    pagerduty_user.user
  ]
}





#data "pagerduty_schedule" "schedule" {
#  for_each = zipmap(
#    distinct(flatten(values(var.services)[*]["rules"]["target"])),
#    distinct(flatten(values(var.services)[*]["rules"]["target"]))
#  )
#  name = each.value
#}

#output "teste2" {
#  value = distinct(
#    flatten(
#      [for k, v in flatten(values(var.services)[*]["rules"]) :
#        [for x in v :
#          x.target
#        ]
#      ]
#    )
#  )
#
#  #value = zipmap(
#  #  distinct(flatten(values(var.services)[*]["rules"])),
#  #  distinct(flatten(values(var.services)[*]["rules"]))
#  #)
#}


#output "pd_int" {
#  #value = pagerduty_service_integration.prometheus.integration_key
#  value = tomap({ for k, v in pagerduty_service_integration.prometheus : k => {
#    pagerduty_key = v.integration_key 
#    pagerduty_name = v.name  
#    }  
#  })
#}