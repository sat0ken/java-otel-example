data "aws_iam_policy" "xray" {
  arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

data "aws_iam_policy" "s3" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "5.0.0"

  architectures = local.arch
  function_name = local.function_name
  handler       = local.handler
  runtime       = local.runtime

  create_package         = false
  local_existing_package = "${path.module}/../demo/build/distributions/demo-no-otel-java11-0.0.1-SNAPSHOT.zip"

  memory_size = 512
  timeout     = 120
  publish     = true

  environment_variables = local.add_otel_layer ? {
    AWS_LAMBDA_EXEC_WRAPPER = "/opt/otel-handler"
  } : {}

  tracing_mode = local.add_otel_layer ?  "Active" : null

  layers = local.add_otel_layer ? [
    local.otel_wrapper_layer_arn
  ] : null

}

resource "aws_iam_role_policy_attachment" "attach-lambda-exec-role" {
  role       = module.lambda.lambda_role_name
  policy_arn = data.aws_iam_policy.xray.arn
}

resource "aws_iam_role_policy_attachment" "attach-lambda-exec-role-s3" {
  role       = module.lambda.lambda_role_name
  policy_arn = data.aws_iam_policy.s3.arn
}
