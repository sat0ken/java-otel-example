data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy" "CloudWatchLogsFullAccess" {
  name = "CloudWatchLogsFullAccess"
}

data "aws_iam_policy" "AmazonSSMReadOnlyAccess" {
  name = "AmazonSSMReadOnlyAccess"
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  name = "AmazonEC2ContainerRegistryReadOnly"
}

data "external" "global_ip" {
  program = ["curl", "httpbin.org/ip"]
}