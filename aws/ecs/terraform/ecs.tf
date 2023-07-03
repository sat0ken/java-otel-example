resource "aws_ecs_cluster" "cluster" {
  name = "${local.user}-ecs-cluster"
}

resource "aws_ecs_task_definition" "service" {
  family             = "aws-otel-FARGATE"
  network_mode       = "awsvpc"
  task_role_arn      = aws_iam_role.task.arn
  execution_role_arn = aws_iam_role.task_exec.arn
  container_definitions = templatefile("${path.module}/json/task_definition.json", {
    cluster_name = aws_ecs_cluster.cluster.name
    otel_command = "--config=/etc/ecs/ecs-default-config.yaml",
    region       = local.region,
    app_image    = local.app_image
    app_name     = local.app_name
  })
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
}

resource "aws_ecs_service" "otel" {
  name = "otel-example"
  cluster = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count = 1
  launch_type = "FARGATE"

  network_configuration {
    subnets = module.vpc.private_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.fargate.arn
    container_name = local.app_name
    container_port = 8080
  }
}

resource "aws_cloudwatch_log_group" "otel" {
  name = "/ecs/${aws_ecs_cluster.cluster.name}/ecs-aws-otel-sidecar-collector"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "sidecar_app" {
  name = "/ecs/${aws_ecs_cluster.cluster.name}/ecs-aws-otel-sidecar-app"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "java_app" {
  name = "/ecs/${aws_ecs_cluster.cluster.name}/${local.app_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "alpine" {
  name = "/ecs/${aws_ecs_cluster.cluster.name}/alpine"
  retention_in_days = 7
}