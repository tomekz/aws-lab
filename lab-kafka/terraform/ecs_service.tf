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
  tags = merge(local.tags, { "Name" = "lab-kafka-ecs-iam-role" })
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

# resource "aws_ecs_service" "lab-kafka-ecs-service" {
#   name            = "lab-kafka-ecs-service"
#   cluster         = aws_ecs_cluster.lab_kafka_ecs_cluster.id
#   # launch_type = "FARGATE" # TODO - find out why this is unsupported
#   scheduling_strategy  = "REPLICA"
#   desired_count        = 1
#   force_new_deployment = true
#   tags = merge(local.tags, { "Name" = "lab-kafka-ecs-service" })
#   task_definition = aws_ecs_task_definition.lab_kafka_service_task_definition.arn
#   network_configuration {
#     subnets = [aws_subnet.private_1.id]
#     assign_public_ip = false
#     security_groups = [
#       aws_security_group.service_security_group.id,
#       aws_security_group.load_balancer_security_group.id
#     ]
#   }
#
#   load_balancer {
#     target_group_arn = aws_lb_target_group.target_group.arn
#     container_name   = "lab-kafka-esc-service-container"
#     container_port   = 8080
#   }
# }

# resource "aws_ecs_task_definition" "lab_kafka_service_task_definition" {
#   family                   = "my-task-definition"
#   container_definitions    = <<TASK_DEF
#   [
#     {
#       "name": "my-container",
#       "image": "redis",
#       "cpu": 256,
#       "memory": 512,
#       "portMappings": [
#         {
#           "containerPort": 80,
#           "hostPort": 0,
#           "protocol": "tcp"
#         }
#       ]
#     }
#   ]
#   TASK_DEF
# }
