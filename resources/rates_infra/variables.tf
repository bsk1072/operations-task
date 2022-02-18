# core

variable "region" {
  description = "The AWS region to create resources"
}


# networking

variable "public_subnet_1_cidr" {
  description = "CIDR Block for Public Subnet 1"
}

variable "public_subnet_2_cidr" {
  description = "CIDR Block for Public Subnet 2"
}
variable "availability_zones" {
  description = "Availability zones for hosting"
  type        = list(string)
}


# load balancer

variable "health_check_path" {
  description = "Health check path for the target group"
}


# ecs

variable "ecs_cluster_name" {
  description = "ECS cluster NAme"
}

variable "amis" {
  description = "AMI used for ecs backend ec2 instance"
}

variable "instance_type" {
}

variable "docker_image_rates" {
  description = "Docker image for ECS cluster, basically the url of the registry"
}

variable "app_count" {
  description = "number of Containers to run"
}
variable "allowed_hosts" {
  description = "Allowing the hosts for connections"
}


# logs

variable "log_retention_in_days" {
}


# key pair

variable "ssh_pubkey_file" {
  description = "ssh key file path"
}


# auto scaling

variable "autoscale_min" {
  description = "Min. autoscale (number of EC2)"
}
variable "autoscale_max" {
  description = "Max. autoscale (number of EC2)"
}
variable "autoscale_desired" {
  description = "Desired count for autoscale (number of EC2)"
}


# rds

variable "rds_db_name" {
  description = "RDS db name"
}
variable "rds_username" {
  description = "RDS db username"
}
variable "rds_password" {
  description = "RDS db password"
}
variable "rds_instance_class" {
  description = "RDS db type"
}
