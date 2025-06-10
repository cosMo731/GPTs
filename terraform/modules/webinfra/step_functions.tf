# Step Functions state machine using external JSON definition.
resource "aws_sfn_state_machine" "this" {
  name       = "${var.prefix}-state-machine"
  role_arn   = var.sfn_role_arn
  definition = file(var.sfn_definition)
}
