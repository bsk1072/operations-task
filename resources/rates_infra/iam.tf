resource "aws_iam_role" "ecs-host-role" {
  name               = "ecs_host_role_dev"
  assume_role_policy = file("${path.module}/../policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs-instance-role-policy" {
  name   = "ecs_instance_role_policy"
  policy = file("${path.module}/../policies/ecs-instance-role-policy.json")
  role   = aws_iam_role.ecs-host-role.id
}

resource "aws_iam_role" "ecs-service-role" {
  name               = "ecs_service_role_dev"
  assume_role_policy = file("${path.module}/../policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs-service-role-policy" {
  name   = "ecs_service_role_policy"
  policy = file("${path.module}/../policies/ecs-service-role-policy.json")
  role   = aws_iam_role.ecs-service-role.id
}

resource "aws_iam_instance_profile" "ecs" {
  name = "ecs_instance_profile_dev"
  path = "/"
  role = aws_iam_role.ecs-host-role.name
}
