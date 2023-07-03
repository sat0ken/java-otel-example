locals {
  region    = "ap-northeast-1"
  user      = "satoken"
  vpc_cidr  = "10.0.0.0/16"
  azs       = slice(data.aws_availability_zones.available.names, 0, 3)
  app_image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/satoken-otel-sample:latest"
  app_name  = "sample-java-app"
  allow_ip  = "${data.external.global_ip.result.origin}/32"
}