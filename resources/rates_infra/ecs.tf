resource "aws_ecs_cluster" "development" {
  name = "${var.ecs_cluster_name}-cluster"
}

resource "aws_launch_configuration" "ecs" {
  name                        = "${var.ecs_cluster_name}-cluster"
  image_id                    = lookup(var.amis, var.region)
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.ecs.id]
  iam_instance_profile        = aws_iam_instance_profile.ecs.name
  key_name                    = aws_key_pair.development.key_name
  associate_public_ip_address = true
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}-cluster' > /etc/ecs/ecs.config"
}

data "template_file" "app" {
  template = file("${path.module}/../templates/rates_app.json.tpl")

  vars = {
    docker_image_rates = var.docker_image_rates
    region                  = var.region
    rds_db_name             = var.rds_db_name
    rds_username            = var.rds_username
    rds_password            = var.rds_password
    rds_hostname            = aws_db_instance.development.address
    allowed_hosts           = var.allowed_hosts
  }
}

resource "aws_ecs_task_definition" "app" {
  family                = "rates-app"
  container_definitions = data.template_file.app.rendered
  depends_on            = [aws_db_instance.development]

  volume {
    name      = "static_volume"
    host_path = "/usr/src/app/staticfiles/"
  }
}

resource "aws_ecs_service" "development" {
  name            = "${var.ecs_cluster_name}-service"
  cluster         = aws_ecs_cluster.development.id
  task_definition = aws_ecs_task_definition.app.arn
  iam_role        = aws_iam_role.ecs-service-role.arn
  desired_count   = var.app_count
  depends_on      = [aws_alb_listener.ecs-alb-http-listener, aws_iam_role_policy.ecs-service-role-policy]

load_balancer {
    target_group_arn = aws_alb_target_group.default-target-group.arn
    container_name   = "rates-app"
    container_port   = 3000
  }
}
