locals {
  region    = "ap-northeast-1"
  user      = "satoken"
  vpc_cidr  = "10.0.0.0/16"
  azs       = slice(data.aws_availability_zones.available.names, 0, 3)
  cluster_version = "1.26"
  app_image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/satoken-otel-sample:latest"
  app_name  = "sample-java-app"
  allow_ip  = ["${data.external.global_ip.result.origin}/32"]

  ingress_nodes_ephemeral_ports_tcp = {
    description                = "Nodes on ephemeral ports"
    protocol                   = "tcp"
    from_port                  = 1025
    to_port                    = 65535
    type                       = "ingress"
    source_node_security_group = true
  }

  ingress_self_all = {
    description = "Node to node all ports/protocols"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    type        = "ingress"
    self        = true
  }

}