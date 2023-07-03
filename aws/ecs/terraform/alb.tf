resource "aws_security_group" "http" {
  name        = "${local.user}-allow-8080-sample-app"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = [local.allow_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb" "for_sample_app" {
  name = "${local.user}-alb"
  internal = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.http.id]
  subnets            = [for subnet in module.vpc.public_subnets: subnet]

  enable_deletion_protection = true
}

resource "aws_lb_target_group" "fargate" {
  name        = "${local.user}-alb-target-group"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    interval = 60
    path = "/health"
    port = 8080
    timeout = 5
    unhealthy_threshold = 3
    matcher = 200
  }
}

resource "aws_lb_listener" "sample_app" {
  load_balancer_arn = aws_lb.for_sample_app.arn
  port              = "8080"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fargate.arn
  }
}