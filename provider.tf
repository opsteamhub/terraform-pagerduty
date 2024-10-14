# Configure the PagerDuty provider
terraform {
  required_providers {
    pagerduty = {
      source  = "pagerduty/pagerduty"
      version = "3.16.0"
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
