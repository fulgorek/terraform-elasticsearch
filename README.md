# Terraform Elasticsearch Module with NodeJs CLI pipeline


### Purpose
The purpose of this project is create a self managed, auto-configured, easy scalable Elasticsearch + Kibana Cluster, using Terraform for Infrastructure and NodeJs for the pipeline.


### Highlighs
Fully automatized Elasticsearch cluster installation and data pipeline with test dataset from https://www.reddit.com/r/datasets/


### Technology
 - Terraform v0.11.7
 - Elasticsearch 6.2.4
 - Kibana 6.2.4
 - nodejs v9.11.1
 - npm 5.6.0
 - AWS


## Terraform module
Terraform module `terraform/modules/elasticsearch`


### Configuration variables for Elasticsearch module:

```
environment
  set environment, used for tagging resources

region
  AWS region

cluster_name
  Cluster name shown in elasticsear, also used for tagging resources

elasticsearch_version
  elasticsearch version to use

project
  project name

vpc_id
  VPC where resources are deployed

master_node_subnets
  subnets where master nodes are deployed

data_node_subnets
  subnets where data nodes are deployed

key_name
  ssh key name from your AWS to use

default_ami
  AMI(AMAZONLINUX) to use.

master_node_count_min
  Min number of master nodes to use for the Auto Scale Group

master_node_count_max
  Max number of master nodes to use for the Auto Scale Group

master_node_public_ip
  Assign public IP to master nodes

master_node_instance_type
  Master node instance type

master_node_volume_type
  Master node volume type

master_node_volume_size
  Master node volume size

data_node_count_min
  Min number of data nodes to use for the Auto Scale Group

data_node_count_max
  Max number of data nodes to use for the Auto Scale Group

data_node_public_ip
  Assign public IP to data nodes

data_node_instance_type
  Data node instance type

data_node_volume_type
  Data node volume type

data_node_volume_size
  Data node volume size
```
#### Note:
All variables accepted are described in `terraform/modules/elasticsearch/variables.tf`


### Resources
 - ASG for master nodes
 - Launch configuration for master nodes
 - ASG for data nodes
 - Launch configuration for data nodes
 - IAM role, policy and aws_iam_instance_profile required to run
 - Security group
 - 2 cloudwatch metric alarms

### Auto configuration
 - Elasticsearch is installed on every instance launched
 - Kibana is only installed on the first Master node launched


## Pipeline module
Pipeline module `pipeline`
The pipeline will create the index, add the records from `pipeline/dataset/reddit-2018-wc-rosters.csv` and will display the Kibana url to access the data.


### Manual run


```
$ npm install && $ HOST=<elasticsearch node> npm start
```


# DEMO SCRIPTS
`terraform.sh`: This script will `pull` information from your AWS account like VPC, Subnets, and find the IP of the MASTER node,then create all the resources.
please refer to `terraform/elasticsearch.tf`


```
$ ./terraform.sh
```


`pipeline.sh`: This script will `pull` IP of the MASTER node, import the dataset, create the indexes and configure Kibana.
please refer to `pipeline/index.js`


```
$ ./pipeline.sh
```

Dataset used: https://www.reddit.com/r/datasets/ (https://www.reddit.com/r/datasets/comments/8sa5vi/world_cup_rosters_stats_and_club_teams_data/)


## Resources created in DEMO
 - 1 Master node with Kibana
 - 2 Data nodes


# STEPS
 - source your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
 - edit `terraform.sh` and change your desired region, default is `us-west-2`
 - run `$ ./terraform.sh`, you'll see your resources created.
 - run `$ ./pipeline.sh`, you'll see your kibana url.


## Destroy AWS resources:
go to `terraform` directory and run `terraform destroy`


# Licence
MIT
