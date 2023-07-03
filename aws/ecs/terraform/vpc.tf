module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name               = "${local.user}-ecs-vpc"
  cidr               = local.vpc_cidr
  azs                = local.azs
  public_subnets     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  enable_nat_gateway = true
  single_nat_gateway = true
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${local.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${local.region}.ecr.api"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "log" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${local.region}.logs"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${local.region}.s3"
  vpc_endpoint_type = "Gateway"
}

resource "aws_security_group_rule" "https" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = [local.vpc_cidr]
  security_group_id = module.vpc.default_security_group_id
}

resource "aws_security_group_rule" "http" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = [local.vpc_cidr]
  security_group_id = module.vpc.default_security_group_id
}

resource "aws_security_group_rule" "egress" {
  type = "egress"
  from_port        = 0
  to_port          = 0
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
  security_group_id = module.vpc.default_security_group_id
}
