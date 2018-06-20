module "elasticsearch_cluster" {
  source = "./modules/elasticsearch"

  region                = "${var.region}"
  project               = "${var.project}"
  environment           = "${var.environment}"
  elasticsearch_version = "6.2.4"

  vpc_id              = "${var.vpc_id}"
  master_node_subnets = "${var.master_node_subnets}"
  data_node_subnets   = "${var.data_node_subnets}"
  key_name            = "${var.key_name}"

  master_node_count_min     = 1
  master_node_count_max     = 1
  master_node_public_ip     = true
  master_node_volume_size   = 60
  master_node_instance_type = "t2.medium"

  data_node_count_min     = 2
  data_node_count_max     = 2
  data_node_public_ip     = false       // Depends on you subnet setting
  data_node_volume_size   = 40
  data_node_instance_type = "t2.medium"
}
