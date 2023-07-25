data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role_policy" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role" "ecs-task-execution-role" {
  name               = "lab-kafka-ecs-service-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = merge(local.tags, { "Name" = "lab-kafka-ecs-iam-role" })
}

resource "aws_security_group" "service_security_group" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.tags, { "Name" = "lab-kafka-lb-sg" })
}

resource "aws_ecs_service" "lab-kafka-ecs-service" {
  name                 = "lab-kafka-ecs-service"
  cluster              = aws_ecs_cluster.lab_kafka_ecs_cluster.id
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true
  launch_type          = "FARGATE"
  tags                 = merge(local.tags, { "Name" = "lab-kafka-ecs-service" })
  task_definition      = aws_ecs_task_definition.lab_kafka_service_task_definition.arn
  network_configuration {
    subnets = [aws_subnet.private_1.id]
    # assign_public_ip = false
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "hello-service"
    container_port   = 3000
  }
}

resource "aws_ecs_task_definition" "lab_kafka_service_task_definition" {
  family                   = "service"
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn            = aws_iam_role.ecs-task-execution-role.arn
  container_definitions    = <<TASK_DEF
  [
    {
    "name": "hello-service", 
    "image": "925303156481.dkr.ecr.eu-central-1.amazonaws.com/lab-kafka-ecr:v0.0.1", 
    "portMappings": [
        {
            "containerPort": 3000, 
            "hostPort": 3000, 
            "protocol": "tcp"
        }
    ], 
    "essential": true
    }
  ]
  TASK_DEF
}

