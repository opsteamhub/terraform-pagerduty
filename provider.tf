# Configure the PagerDuty provider
terraform {
  required_providers {
    pagerduty = {
      source = "pagerduty/pagerduty"
      # 3.33.0 é a primeira versão que aceita whatsapp_contact_method em
      # pagerduty_user_notification_rule, usado em user.tf.
      version = "3.33.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1"
    }
  }
}


provider "pagerduty" {
  token      = var.pagerduty_token
  user_token = var.pagerduty_user_token
}
