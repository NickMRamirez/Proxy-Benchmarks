variable "aws_region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "aws_instance_type" {
  description = "AWS instance type for nodes"
  default     = "m5.xlarge"
}

variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "ssh_keypair_name" {
  default = "benchmarks"
}
