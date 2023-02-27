resource "pagerduty_schedule" "schedule" {
  for_each  = var.schedule
  name      = each.value["name"]
  time_zone = each.value["time_zone"]

  depends_on = [
    pagerduty_user.user
  ]

  layer {
    name                         = each.value["layer_name"]
    start                        = each.value["start"]
    rotation_virtual_start       = each.value["rotation_virtual_start"]
    rotation_turn_length_seconds = each.value["rotation_turn_length_seconds"]
    users                        = [ for x in each.value["users"]:
      data.pagerduty_user.users[x].id
    ]

    restriction {
      type              = each.value["type"]
      start_time_of_day = each.value["start_time_of_day"]
      duration_seconds  = each.value["duration_seconds"]
      start_day_of_week = each.value["start_day_of_week"]
    }
  }
}


data "pagerduty_user" "users" {
  for_each = zipmap(
    distinct(flatten(values(var.schedule)[*]["users"])),
    distinct(flatten(values(var.schedule)[*]["users"]))
  )
  email = each.value
  
  depends_on = [
    pagerduty_user.user
  ]
}

output "teste" {
  value = zipmap(
    distinct(flatten(values(var.schedule)[*]["users"])),
    distinct(flatten(values(var.schedule)[*]["users"]))
  )
}

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
      [ for k,v in flatten(values(var.services)[*]["rules"]):
        [ for x in v:
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