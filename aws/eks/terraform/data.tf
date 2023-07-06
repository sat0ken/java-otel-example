data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

data "external" "global_ip" {
  program = ["curl", "httpbin.org/ip"]
}