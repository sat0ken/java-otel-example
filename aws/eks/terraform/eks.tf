module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.14.0"

  cluster_name                         = "${local.user}-cluster"
  cluster_version                      = local.cluster_version
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = local.allow_ip
  iam_role_additional_policies = {
    additional = aws_iam_policy.additional.arn
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = local.ingress_nodes_ephemeral_ports_tcp
  }

  node_security_group_additional_rules = {
    ingress_self_all = local.ingress_self_all
  }

  # https://github.com/clowdhaus/eks-reference-architecture/blob/main/serverless/eks.tf#L13-L36
  cluster_addons = {
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
        # Ensure that the we fully utilize the minimum amount of resources that are supplied by
        # Fargate https://docs.aws.amazon.com/eks/latest/userguide/fargate-pod-configuration.html
        # Fargate adds 256 MB to each pod's memory reservation for the required Kubernetes
        # components (kubelet, kube-proxy, and containerd). Fargate rounds up to the following
        # compute configuration that most closely matches the sum of vCPU and memory requests in
        # order to ensure pods always have the resources that they need to run.
        resources = {
          limits = {
            cpu = "0.25"
            # We are targetting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
          requests = {
            cpu = "0.25"
            # We are targetting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
        }
      })
    }
  }

  # Fargate Profile(s)
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        },
        {
          namespace = "default"
        },
        {
          namespace = "fargate-container-insights"
        },
        {
          namespace = "cert-manager"
        }
      ]

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
  }

  aws_auth_fargate_profile_pod_execution_role_arns = [
    module.fargate_profile.fargate_profile_pod_execution_role_arn
  ]

  aws_auth_users = [
    {
      userarn  = data.aws_caller_identity.current.arn,
      username = "admin"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_roles = [
    {
      rolearn  = module.fargate_profile.fargate_profile_pod_execution_role_arn
      username = "system:node:{{SessionName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
        "system:node-proxier",
      ]
    }
  ]

  kms_key_administrators = [
    data.aws_caller_identity.current.arn
  ]

}

module "fargate_profile" {
  source  = "terraform-aws-modules/eks/aws//modules/fargate-profile"
  version = "19.14.0"

  name         = "${local.user}-separate-fargate-profile"
  cluster_name = module.eks.cluster_name

  subnet_ids = module.vpc.private_subnets
  selectors = [
    {
      namespace = "kube-system"
    }
  ]
}

resource "aws_iam_policy" "additional" {
  name = "${local.user}-eks-cluster-additional-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

