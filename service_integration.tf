data "pagerduty_vendor" "prometheus" {
  for_each = { for k, v in var.services :
    k => v if try(v["service_integration"], false) == true
  }
  name = each.value["service_integration_vendor"]
}

resource "pagerduty_service_integration" "prometheus" {
  for_each = { for k, v in var.services :
    k => v if try(v["service_integration"], false) == true
  }
  name    = join("-", [data.pagerduty_vendor.prometheus[each.key].name, each.key])
  service = pagerduty_service.service[each.key].id
  vendor  = data.pagerduty_vendor.prometheus[each.key].id
}


output "pd_int" {
  #value = pagerduty_service_integration.prometheus.integration_key
  value = tomap({ for k, v in pagerduty_service_integration.prometheus : k => {
    pagerduty_key = v.integration_key 
    pagerduty_name = v.name  
    }  
  })
}


#output "pagerduty_key" {
#  value = regex("[0-9[aA-zZ-]+[^=]$", replace(replace(replace(replace(jsonencode({for k, v in pagerduty_service_integration.prometheus : k => v.integration_key}), "\"", ""), ":", "="), "{", ""), "}", ""))
#}
#
#output "integration_name" {
#  value = regex("[aA-zZ-]+[^=]$", replace(replace(replace(replace(jsonencode({ for k, v in pagerduty_service_integration.prometheus : k => v.name  }), "\"", ""), ":", "="), "{", ""), "}", ""))
#}

output "service_integration" {
  value = pagerduty_service_integration.prometheus
}