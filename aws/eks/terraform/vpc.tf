module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name               = "${local.user}-eks-vpc"
  cidr               = local.vpc_cidr
  azs                = local.azs
  public_subnets     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]
  enable_nat_gateway = true

  # LBの配置に必要なタグ
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  # LBの配置に必要なタグ
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

