variable "project" {
  type        = "string"
  description = "project Name"
  default     = "myproject"
}

variable "environment" {
  type        = "string"
  description = "Your application environment"
  default     = "development"
}

variable "region" {
  type        = "string"
  description = "AWS region to use"
}

variable "vpc_id" {
  type        = "string"
  description = "VPC to use"
}

variable "master_node_subnets" {
  type        = "string"
  description = "Comma separated list of subnets"
}

variable "data_node_subnets" {
  type        = "string"
  description = "Comma separated list of subnets"
}

variable "key_name" {
  type        = "string"
  description = "Your instances default ssh key to use"
  default     = ""
}
