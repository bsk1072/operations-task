# core

variable "region" {
  description = "The AWS region to create resources"
  default     = "eu-west-1"
}


# networking

variable "public_subnet_1_cidr" {
  description = "CIDR Block for Public Subnet 1"
  default     = "<CIDR Range>"
}

variable "public_subnet_2_cidr" {
  description = "CIDR Block for Public Subnet 2"
  default     = "<CIDR Range>"
}
variable "availability_zones" {
  description = "Availability zones for hosting"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}


# load balancer

variable "health_check_path" {
  description = "Health check path for the target group"
  default     = "/ping/"
}


# ecs

variable "ecs_cluster_name" {
  description = "ECS cluster NAme"
  default     = "development"
}

variable "amis" {
  description = "AMI used for ecs backend ec2 instance"
   default = {
    eu-west-1 = "ami-0bf84c42e04519c85"
  }
}

variable "instance_type" {
	default = "t2.micro"
}

variable "docker_image_rates" {
  description = "Docker image for ECS cluster, basically the url of the registry"
  default     = "<AWS Account id>.dkr.ecr.eu-west-1.amazonaws.com/rates-ecr:latest"
}

variable "app_count" {
  description = "number of Containers to run"
  default     = 2
}
variable "allowed_hosts" {
  description = "Allowing the hosts for connections"
  default     = "0.0.0.0/0"
}


# logs

variable "log_retention_in_days" {
	default = 30
}


# key pair

variable "ssh_pubkey_file" {
  description = "ssh key file path"
  default     = "~/.ssh/id_rsa.pub"
}


# auto scaling

variable "autoscale_min" {
  description = "Min. autoscale (number of EC2)"
  default     = "1"
}
variable "autoscale_max" {
  description = "Max. autoscale (number of EC2)"
  default     = "4"
}
variable "autoscale_desired" {
  description = "Desired count for autoscale (number of EC2)"
  default     = "2"
}


# rds

variable "rds_db_name" {
  description = "RDS db name"
  default     = "rates"
}
variable "rds_username" {
  description = "RDS db username"
  default     = "postgres"
}
variable "rds_password" {
  description = "RDS db password"
  default     = "<DBPASSWORD>"
}
variable "rds_instance_class" {
  description = "RDS db type"
  default     = "db.t2.micro"
}

