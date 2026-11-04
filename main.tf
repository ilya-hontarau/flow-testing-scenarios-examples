data "flows_project" "this" {
  name = var.project_name
}


locals {
  project_id = data.flows_project.this.id

  flows = {
    order_pipeline      = { name = "1. Order pipeline", file = "01-order-pipeline.yaml" }
    failures            = { name = "2. Failures, timeouts & cancel", file = "02-failures-timeouts-cancel.yaml" }
    mocked_spacelift    = { name = "4. Mocked Spacelift task with a delayed reply", file = "04-mocked-spacelift-task-with-a-delayed-reply.yaml" }
    collect             = { name = "5. Collect: two entry points & same block twice", file = "05-collect-two-entry-points-same-block-twice.yaml" }
    run_events          = { name = "6. Run Events -> live Trigger Run", file = "06-run-events-live-trigger-run.yaml" }
    only_business_logic = { name = "7. Only business logic", file = "07-only-business-logic.yaml" }
    core_edge_cases     = { name = "8. Core edge cases", file = "08-core-edge-cases.yaml" }
  }
}

# Flows 1, 2, 4, 5, 6, 7, 8.
resource "flows_flow" "this" {
  for_each = local.flows

  project_id = local.project_id
  name       = each.value.name
  definition = replace(file("${path.module}/flows/${each.value.file}"), "REPLACE-WITH-STACK-ID", var.spacelift_stack_id)

  # Only flow 4 uses an app (Slack); its YAML has no installation ID, so map it here.
  app_installation_mapping = each.key == "mocked_spacelift" ? {
    slack = var.slack_installation_id
  } : null

  depends_on = [flows_secret.scenario_test_secret]
}

# Flow 8 reads secrets.SCENARIO_TEST_SECRET.
resource "flows_secret" "scenario_test_secret" {
  project_id = local.project_id
  key        = "SCENARIO_TEST_SECRET"
  value      = var.scenario_test_secret
}

# Flow 3: the definition references a `ticks` data table. Through the API it has
# to exist already, so we create it here and point the definition at its ID.
resource "flows_data_table" "ticks" {
  project_id = local.project_id
  name       = "ticks"
}

resource "flows_data_table_column" "ticks_source" {
  data_table_id = flows_data_table.ticks.id
  name          = "source"
  type          = "string"
}

resource "flows_flow" "isolation" {
  project_id = local.project_id
  name       = "3. Isolation (schedule + data table)"
  enabled    = var.isolation_flow_enabled
  definition = replace(
    file("${path.module}/flows/03-isolation.yaml"),
    "  ticks:\n    schema:",
    "  ticks:\n    id: ${flows_data_table.ticks.id}\n    schema:",
  )

  depends_on = [flows_data_table_column.ticks_source]
}

resource "flows_data_table_attachment" "ticks" {
  data_table_id = flows_data_table.ticks.id
  flow_id       = flows_flow.isolation.id
}

output "flow_ids" {
  value = merge(
    { for k, f in flows_flow.this : k => f.id },
    { isolation = flows_flow.isolation.id },
  )
}
