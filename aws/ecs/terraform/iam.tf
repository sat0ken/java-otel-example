resource "aws_iam_policy" "policy_otel" {
  name   = "${local.user}-AWSDistroOpenTelemetryPolicy"
  path   = "/"
  policy = file("${path.module}/json/otel_policy.json")
}

resource "aws_iam_role" "task" {
  name = "${local.user}-AWSOTTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          "Service" : "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_role_policy_attachment" "attach_task" {
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.policy_otel.arn
}

resource "aws_iam_role" "task_exec" {
  name = "${local.user}-AWSOTTaskExcutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          "Service" : "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_role_policy_attachment" "attach_ecs" {
  role       = aws_iam_role.task_exec.name
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
}

resource "aws_iam_role_policy_attachment" "attach_cw" {
  role       = aws_iam_role.task_exec.name
  policy_arn = data.aws_iam_policy.CloudWatchLogsFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "attach_ssm" {
  role       = aws_iam_role.task_exec.name
  policy_arn = data.aws_iam_policy.AmazonSSMReadOnlyAccess.arn
}

resource "aws_iam_role_policy_attachment" "attach_ecr" {
  role       = aws_iam_role.task_exec.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
}