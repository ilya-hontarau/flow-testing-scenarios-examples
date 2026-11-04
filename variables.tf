variable "flows_endpoint" {
  description = "Flows endpoint, usually useflows.eu or useflows.us."
  type        = string
  default     = "useflows.eu"
}

variable "project_name" {
  description = "Name of the Flows project to create the test flows in."
  type        = string
}

variable "slack_installation_id" {
  description = "ID of an existing Slack app installation in the project (used by flow 4)."
  type        = string
}

variable "spacelift_stack_id" {
  description = "Real Spacelift stack ID used by flows 4 and 6. Requires a linked Spacelift account."
  type        = string
  default     = "REPLACE-WITH-STACK-ID"
}

variable "scenario_test_secret" {
  description = "Value of the SCENARIO_TEST_SECRET project secret used by flow 8."
  type        = string
  default     = "hello"
  sensitive   = true
}

variable "isolation_flow_enabled" {
  description = "Flow 3 has a real Schedule that ticks every minute and writes rows; disable it when you're done."
  type        = bool
  default     = true
}
