aws_region  = "us-east-1"
aws_region_alias = "use1"
env         = "dev"
chef_env    = "dev"
aws_profile = "sagar-devops"
vpc_cidr = "10.25.0.0/16"
vpc_public_subnets = ["10.25.101.0/24", "10.25.111.0/24"]
vpc_private_subnets = ["10.25.110.0/24", "10.25.120.0/24"]
vpc_azs = ["us-east-1a", "us-east-1c"]

amz1_ami = { us-east-1  = "ami-55ef662f" }
ecs_ami = { us-east-1 = "ami-0796380bc6e51157f" }

service_cluster_instance_type = "t2.micro"
service_cluster_desired_instance = "1"
service_cluster_min_instance = "1"
service_cluster_max_instance = "1"
