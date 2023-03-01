data "pagerduty_priority" "p1" {
  for_each = var.services
  name     = each.value["priority_name"]
}

resource "pagerduty_slack_connection" "slack" {
  for_each = { for k, v in var.services :
    k => v if try(v["slack_integration"], false) == true
  }

  source_id         = pagerduty_service.service[each.key].id
  source_type       = each.value["source_type"]
  workspace_id      = each.value["workspace_id"]
  channel_id        = each.value["channel_id"]
  notification_type = each.value["notification_type"]
  config {
    events = [
      "incident.triggered",
      "incident.acknowledged",
      "incident.escalated",
      "incident.resolved",
      "incident.reassigned",
      "incident.annotated",
      "incident.unacknowledged",
      "incident.delegated",
      "incident.priority_updated",
      "incident.responder.added",
      "incident.responder.replied",
      "incident.status_update_published",
      "incident.reopened"
    ]
    priorities = [pagerduty_priority.p1[each.key].id]

  }
}