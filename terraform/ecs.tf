resource "aws_ecs_cluster" "this" {
  name = "guacamole-cluster"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "guacamole"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn = data.aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "guacamole"
      image = "guacamole/guacamole:latest"

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      essential = true

      # ★ 環境変数は「空」！！
      environment = []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/guacamole"
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "guacamole"
        }
      }
    }
  ])
}


resource "aws_ecs_service" "this" {
  name            = "guacamole"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_a.id, aws_subnet.public_c.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
}

resource "aws_cloudwatch_log_group" "guacamole" {
  name              = "/ecs/guacamole"
  retention_in_days = 3
}
