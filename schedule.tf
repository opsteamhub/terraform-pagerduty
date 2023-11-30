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
      name                         = layers.key
      start                        = layers.value["start"]
      rotation_virtual_start       = layers.value["rotation_virtual_start"]
      rotation_turn_length_seconds = layers.value["rotation_turn_length_seconds"]
      users = [for x in layers.value["users"] :
        data.pagerduty_user.users[x].id
      ]

    }
  }

  #  #restriction {
  #  #  type              = each.value["type"] 
  #  #  start_time_of_day = each.value["start_time_of_day"]
  #  #  duration_seconds  = each.value["duration_seconds"]
  #  #  start_day_of_week = each.value["type"]  == "weekly_restriction" ? each.value["start_day_of_week"] : null
  #  #}
  #}
}

data "pagerduty_user" "users" {
  for_each = zipmap(
    #flatten(distinct(flatten(values(var.schedule)[*]["layer"])[*]["users"])),
    #flatten(distinct(flatten(values(var.schedule)[*]["layer"])[*]["users"]))
    distinct(flatten([for layers in values(var.schedule.weekdays.layers) : layers.users])),
    distinct(flatten([for layers in values(var.schedule.weekdays.layers) : layers.users]))
  )
  email = each.value


  depends_on = [
    pagerduty_user.user
  ]
}
#
#output "teste" {
#  value = distinct(flatten([for layer in values(var.schedule.weekdays.layer) : layer.users]))
#}

#data "pagerduty_schedule" "schedule" {
#  for_each = zipmap(
#    distinct(flatten(values(var.services)[*]["rules"]["target"])),
#    distinct(flatten(values(var.services)[*]["rules"]["target"]))
#  )
#  name = each.value
#}

output "teste2" {
  value = distinct(
    flatten(
      [for k, v in flatten(values(var.services)[*]["rules"]) :
        [for x in v :
          x.target
        ]
      ]
    )
  )

  #value = zipmap(
  #  distinct(flatten(values(var.services)[*]["rules"])),
  #  distinct(flatten(values(var.services)[*]["rules"]))
  #)
}


#output "pd_int" {
#  #value = pagerduty_service_integration.prometheus.integration_key
#  value = tomap({ for k, v in pagerduty_service_integration.prometheus : k => {
#    pagerduty_key = v.integration_key 
#    pagerduty_name = v.name  
#    }  
#  })
#}