variable "environment" {}
variable "region" {}

variable "cluster_name" {
  type    = "string"
  default = "my-cluster"
}

variable "elasticsearch_version" {
  type    = "string"
  default = "6.2.4"
}

variable "project" {
  type    = "string"
  default = "project-name"
}

variable "vpc_id" {
  type = "string"
}

variable "master_node_subnets" {
  type = "string"
}

variable "data_node_subnets" {
  type = "string"
}

variable "key_name" {
  type    = "string"
  default = ""
}

variable "default_ami" {
  type    = "string"
  default = ""
}

# Master nodes
variable "master_node_count_min" {
  type    = "string"
  default = 1
}

variable "master_node_count_max" {
  type    = "string"
  default = 1
}

variable "master_node_public_ip" {
  type    = "string"
  default = true
}

variable "master_node_instance_type" {
  type    = "string"
  default = "t2.micro"
}

variable "master_node_volume_type" {
  type    = "string"
  default = "gp2"
}

variable "master_node_volume_size" {
  type    = "string"
  default = 20
}

# Data Node
variable "data_node_count_min" {
  type        = "string"
  description = "describe your variable"
  default     = 2
}

variable "data_node_count_max" {
  type        = "string"
  description = "describe your variable"
  default     = 2
}

variable "data_node_public_ip" {
  type    = "string"
  default = false
}

variable "data_node_instance_type" {
  type    = "string"
  default = "t2.micro"
}

variable "data_node_volume_type" {
  type    = "string"
  default = "gp2"
}

variable "data_node_volume_size" {
  type    = "string"
  default = 40
}
