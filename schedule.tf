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
    users                        = [data.pagerduty_user.users[each.key].id]
    restriction {
      type              = each.value["type"]
      start_time_of_day = each.value["start_time_of_day"]
      duration_seconds  = each.value["duration_seconds"]
      start_day_of_week = each.value["start_day_of_week"]
    }
  }
}
