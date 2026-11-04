# Flow testing scenario examples

The 8 test flows from the "Testing Flows Testing" sheet (tab "Example flows"), managed with the
`spacelift-io/flows` Terraform provider. Each flow's YAML, including its `testScenarios`, is in `flows/`.
You can also paste any of those files straight into an empty flow's canvas.

## Usage

```sh
export FLOWS_TOKEN=sf_api...
cp terraform.tfvars.example terraform.tfvars   # fill in project + Slack installation ID
tofu init
tofu apply
```

## What needs setting up

| Flow | Needs |
|------|-------|
| 3. Isolation | Terraform creates the `ticks` data table (column `source`), attaches it, and injects its ID into the YAML. The Schedule really fires every minute, so set `isolation_flow_enabled = false` (or destroy it) when you're done. |
| 4. Mocked Spacelift task | `slack_installation_id`: an existing Slack installation (copies use the same installation). For "live spacelift task", set `spacelift_stack_id`. |
| 6. Run Events | `spacelift_stack_id` (replaced in 3 places) and a linked Spacelift account. |
| 8. Core edge cases | Terraform creates the project secret `SCENARIO_TEST_SECRET` (default `hello`). For "memory starts empty", set the memory key in the source flow by hand. |

The "how to use / what to check" steps for each flow are in the sheet and in each scenario's `description`.
