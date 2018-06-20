variable "environment" {
  description = "set environment, used for tagging resources"
  type        = "string"
}

variable "region" {
  description = "AWS region"
  type        = "string"
}

variable "cluster_name" {
  description = "Cluster name shown in elasticsear, also used for tagging resources"
  type        = "string"
  default     = "my-cluster"
}

variable "elasticsearch_version" {
  description = "elasticsearch version to use"
  type        = "string"
  default     = "6.2.4"
}

variable "project" {
  description = "project name"
  type        = "string"
  default     = "project-name"
}

variable "vpc_id" {
  description = "VPC where resources are deployed"
  type        = "string"
}

variable "master_node_subnets" {
  description = "subnets where master nodes are deployed"
  type        = "string"
}

variable "data_node_subnets" {
  description = "subnets where data nodes are deployed"
  type        = "string"
}

variable "key_name" {
  description = "ssh key name from your AWS to use"
  type        = "string"
  default     = ""
}

variable "default_ami" {
  description = "AMI(AMAZONLINUX) to use."
  type        = "string"
  default     = ""
}

# Master nodes
variable "master_node_count_min" {
  description = "Min number of master nodes to use for the Auto Scale Group"
  type        = "string"
  default     = 1
}

variable "master_node_count_max" {
  description = "Max number of master nodes to use for the Auto Scale Group"
  type        = "string"
  default     = 1
}

variable "master_node_public_ip" {
  description = "Assign public IP to master nodes"
  type        = "string"
  default     = true
}

variable "master_node_instance_type" {
  description = "Master node instance type"
  type        = "string"
  default     = "t2.micro"
}

variable "master_node_volume_type" {
  description = "Master node volume type"
  type        = "string"
  default     = "gp2"
}

variable "master_node_volume_size" {
  description = "Master node volume size"
  type        = "string"
  default     = 20
}

# Data Node
variable "data_node_count_min" {
  description = "Min number of data nodes to use for the Auto Scale Group"
  type        = "string"
  default     = 2
}

variable "data_node_count_max" {
  description = "Max number of data nodes to use for the Auto Scale Group"
  type        = "string"
  default     = 2
}

variable "data_node_public_ip" {
  description = "Assign public IP to data nodes"
  type        = "string"
  default     = false
}

variable "data_node_instance_type" {
  description = "Data node instance type"
  type        = "string"
  default     = "t2.micro"
}

variable "data_node_volume_type" {
  description = "Data node volume type"
  type        = "string"
  default     = "gp2"
}

variable "data_node_volume_size" {
  description = "Data node volume size"
  type        = "string"
  default     = 40
}
