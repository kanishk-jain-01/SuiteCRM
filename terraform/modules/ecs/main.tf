# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.name_prefix}-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cluster"
  })
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids
  
  enable_deletion_protection = false
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb"
  })
}

# Target Groups
resource "aws_lb_target_group" "suitecrm" {
  name     = "${var.name_prefix}-suitecrm-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  
  # Add deregistration delay for smoother deployments
  deregistration_delay = var.deregistration_delay
  
  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = "200"
    path                = "/health.php"        # Use dedicated health check endpoint
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-suitecrm-tg"
  })
}

resource "aws_lb_target_group" "chatbot" {
  name     = "${var.name_prefix}-chatbot-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-chatbot-tg"
  })
}

# ALB Listeners
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.certificate_arn != "" ? "443" : "80"
  protocol          = var.certificate_arn != "" ? "HTTPS" : "HTTP"
  ssl_policy        = var.certificate_arn != "" ? "ELBSecurityPolicy-TLS-1-2-2017-01" : null
  certificate_arn   = var.certificate_arn != "" ? var.certificate_arn : null
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.suitecrm.arn
  }
}

# Redirect HTTP to HTTPS if certificate is provided
resource "aws_lb_listener" "redirect" {
  count = var.certificate_arn != "" ? 1 : 0
  
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type = "redirect"
    
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Listener Rules
resource "aws_lb_listener_rule" "chatbot" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 100
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.chatbot.arn
  }
  
  condition {
    path_pattern {
      values = ["/api/chatbot/*"]
    }
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.name_prefix}-ecs-task-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Role for ECS Tasks
resource "aws_iam_role" "ecs_task" {
  name = "${var.name_prefix}-ecs-task-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.tags
}

# IAM Policy for ECS Tasks
resource "aws_iam_role_policy" "ecs_task" {
  name = "${var.name_prefix}-ecs-task-policy"
  role = aws_iam_role.ecs_task.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          var.db_secret_arn,
          aws_secretsmanager_secret.openai_api_key.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

# Secrets for environment variables
resource "aws_secretsmanager_secret" "openai_api_key" {
  name                    = "${var.name_prefix}-openai-api-key"
  description             = "OpenAI API key for chatbot"
  recovery_window_in_days = 7
  
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "openai_api_key" {
  secret_id     = aws_secretsmanager_secret.openai_api_key.id
  secret_string = var.openai_api_key
}

# SuiteCRM OAuth credentials secret
resource "aws_secretsmanager_secret" "suitecrm_oauth" {
  name                    = "${var.name_prefix}-suitecrm-oauth"
  description             = "SuiteCRM OAuth credentials for chatbot"
  recovery_window_in_days = 7
  
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "suitecrm_oauth" {
  secret_id = aws_secretsmanager_secret.suitecrm_oauth.id
  secret_string = jsonencode({
    client_id     = var.suitecrm_client_id
    client_secret = var.suitecrm_client_secret
    username      = var.suitecrm_username
    password      = var.suitecrm_password
  })
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "suitecrm" {
  name              = "/ecs/${var.name_prefix}/suitecrm"
  retention_in_days = 7
  
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "chatbot" {
  name              = "/ecs/${var.name_prefix}/chatbot"
  retention_in_days = 7
  
  tags = var.tags
}

# ECS Task Definitions
resource "aws_ecs_task_definition" "suitecrm" {
  family                   = "${var.name_prefix}-suitecrm"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn           = aws_iam_role.ecs_task.arn
  
  container_definitions = jsonencode([
    {
      name  = "suitecrm"
      image = "${var.ecr_repository_url}:${var.image_tag}"
      
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "DB_HOST"
          value = split(":", var.db_host)[0]
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
        {
          name  = "DB_USER"
          value = var.db_username
        },
        {
          name  = "DB_CHARSET"
          value = var.db_charset
        },
        {
          name  = "DB_COLLATION"
          value = var.db_collation
        },
        {
          name  = "SITE_URL"
          value = var.site_url != "" ? var.site_url : "https://${var.domain_name != "" ? var.domain_name : aws_lb.main.dns_name}"
        },
        {
          name  = "SYSTEM_NAME"
          value = var.system_name
        },
        {
          name  = "ADMIN_USERNAME"
          value = var.admin_username
        },
        {
          name  = "ADMIN_PASSWORD"
          value = var.admin_password
        },
        {
          name  = "CHATBOT_API_URL"
          value = "https://${var.domain_name != "" ? var.domain_name : aws_lb.main.dns_name}/api/chatbot"
        },
        {
          name  = "PHP_MEMORY_LIMIT"
          value = "512M"
        },
        {
          name  = "PHP_UPLOAD_MAX_FILESIZE"
          value = "50M"
        },
        {
          name  = "PHP_POST_MAX_SIZE"
          value = "50M"
        }
      ]
      
      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.db_secret_arn}:password::"
        }
      ]
      
      mountPoints = [
        {
          sourceVolume  = "uploads"
          containerPath = "/var/www/html/upload"
        },
        {
          sourceVolume  = "cache"
          containerPath = "/var/www/html/cache"
        },
        {
          sourceVolume  = "logs"
          containerPath = "/var/www/html/logs"
        },
        {
          sourceVolume  = "config-persistence"
          containerPath = "/var/www/html/config-persistence"
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.suitecrm.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
      
      healthCheck = {
        command = ["CMD-SHELL", "curl -f http://localhost/health.php || exit 1"]
        interval = 30
        timeout = 10
        retries = 3
        startPeriod = 180
      }
      
      essential = true
    }
  ])
  
  volume {
    name = "uploads"
    efs_volume_configuration {
      file_system_id          = var.efs_file_system_id
      transit_encryption      = "ENABLED"
    }
  }
  
  volume {
    name = "cache"
    efs_volume_configuration {
      file_system_id          = var.efs_file_system_id
      transit_encryption      = "ENABLED"
    }
  }
  
  volume {
    name = "logs"
    efs_volume_configuration {
      file_system_id          = var.efs_file_system_id
      transit_encryption      = "ENABLED"
    }
  }
  
  volume {
    name = "config-persistence"
    efs_volume_configuration {
      file_system_id          = var.efs_file_system_id
      transit_encryption      = "ENABLED"
    }
  }
  
  tags = var.tags
}

resource "aws_ecs_task_definition" "chatbot" {
  family                   = "${var.name_prefix}-chatbot"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn           = aws_iam_role.ecs_task.arn
  
  container_definitions = jsonencode([
    {
      name  = "chatbot"
      image = "${var.chatbot_ecr_repository_url}:${var.image_tag}"
      
      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "SUITECRM_BASE_URL"
          value = "http://${aws_lb.main.dns_name}/Api/V8/"
        },
        {
          name  = "LOG_LEVEL"
          value = "INFO"
        },
        {
          name  = "PYTHONPATH"
          value = "/app"
        },
        {
          name  = "PYTHONUNBUFFERED"
          value = "1"
        }
      ]
      
      secrets = [
        {
          name      = "OPENAI_API_KEY"
          valueFrom = aws_secretsmanager_secret.openai_api_key.arn
        },
        {
          name      = "SUITECRM_CLIENT_ID"
          valueFrom = "${aws_secretsmanager_secret.suitecrm_oauth.arn}:client_id::"
        },
        {
          name      = "SUITECRM_CLIENT_SECRET"
          valueFrom = "${aws_secretsmanager_secret.suitecrm_oauth.arn}:client_secret::"
        },
        {
          name      = "SUITECRM_USERNAME"
          valueFrom = "${aws_secretsmanager_secret.suitecrm_oauth.arn}:username::"
        },
        {
          name      = "SUITECRM_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.suitecrm_oauth.arn}:password::"
        }
      ]
      
      mountPoints = [
        {
          sourceVolume  = "chatbot-logs"
          containerPath = "/app/logs"
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.chatbot.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
      
      healthCheck = {
        command = ["CMD-SHELL", "curl -f http://localhost:8000/health || exit 1"]
        interval = 30
        timeout = 10
        retries = 3
        startPeriod = 30
      }
      
      essential = true
    }
  ])
  
  volume {
    name = "chatbot-logs"
    efs_volume_configuration {
      file_system_id          = var.efs_file_system_id
      transit_encryption      = "ENABLED"
    }
  }
  
  tags = var.tags
}

# ECS Services
resource "aws_ecs_service" "suitecrm" {
  name            = "${var.name_prefix}-suitecrm-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.suitecrm.arn
  desired_count   = var.suitecrm_desired_count
  launch_type     = "FARGATE"
  enable_execute_command = true
  
  # Health check grace period to allow SuiteCRM to fully initialize
  health_check_grace_period_seconds = var.health_check_grace_period
  
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.suitecrm.arn
    container_name   = "suitecrm"
    container_port   = 80
  }
  
  depends_on = [aws_lb_listener.main]
  
  tags = var.tags
}

resource "aws_ecs_service" "chatbot" {
  name            = "${var.name_prefix}-chatbot-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.chatbot.arn
  desired_count   = var.chatbot_desired_count
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.chatbot.arn
    container_name   = "chatbot"
    container_port   = 8000
  }
  
  depends_on = [aws_lb_listener.main]
  
  tags = var.tags
}

# Data source for current AWS region
data "aws_region" "current" {}