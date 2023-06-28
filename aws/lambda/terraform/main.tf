data "aws_iam_policy" "xray" {
  arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "5.0.0"

  architectures = local.arch
  function_name = local.function_name
  handler       = local.handler
  runtime       = local.runtime

  create_package         = false
  local_existing_package = "${path.module}/../demo/build/distributions/demo-0.0.1-SNAPSHOT.zip"

  memory_size = 512
  timeout     = 15
  publish     = true

  environment_variables = {
    AWS_LAMBDA_EXEC_WRAPPER = "/opt/otel-handler"
  }

  # tracing_mode = "Active"

  # layers = [
  #   local.otel_layer_arn
  # ]

}

resource "aws_iam_role_policy_attachment" "attach-lambda-exec-role" {
  role       = module.lambda.lambda_role_name
  policy_arn = data.aws_iam_policy.xray.arn
}
