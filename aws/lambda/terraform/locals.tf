locals {
  arch           = ["x86_64"]
  function_name  = "satoken-java-otel"
  handler        = "com.example.demo.lambda.DemoApplication::handleRequest"
  runtime        = "java17"
  add_otel_layer = false
  otel_layer_arn = "arn:aws:lambda:ap-northeast-1:901920570463:layer:aws-otel-java-agent-amd64-ver-1-26-0:2"
}