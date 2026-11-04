terraform {
  # flows_secret.value is a write-only attribute (OpenTofu >= 1.11, Terraform >= 1.11).
  required_version = ">= 1.11"

  required_providers {
    flows = {
      source = "spacelift-io/flows"
    }
  }
}

provider "flows" {
  endpoint = var.flows_endpoint
  # Token is read from the FLOWS_TOKEN env var (get one with `flowctl auth token`).
}
