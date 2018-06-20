#!/usr/bin/env bash

[[ $${EUID} -ne 0 ]] && echo "Please run as root" && exit 1

# some upgrades
yum update -y &>/dev/null
JAVA_VER=$(java -version 2>&1 | sed -n ';s/.* version "\(.*\)\.\(.*\)\..*"/\1\2/p;')
[[ $${JAVA_VER} != "18" ]] && yum install -y java-1.8.0 && yum remove -y java-1.7.0

# Install and enable ES
[[ ! -f /etc/init.d/elasticsearch ]] && rpm -i https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${elasticsearch_version}.rpm
chkconfig | grep elasticsearch &>/dev/null
[[ $? -eq 1 ]] && chkconfig --add elasticsearch
sed -i '/MAX_LOCKED_MEMORY=unlimited/s/^#//g' /etc/sysconfig/elasticsearch

# Install discovery plugin for EC2
/usr/share/elasticsearch/bin/elasticsearch-plugin list | grep discovery-ec2 &>/dev/null
[[ $? -eq 1 ]] && /usr/share/elasticsearch/bin/elasticsearch-plugin install discovery-ec2 --batch --silent

# Configure nodes
MASTERS=$(aws ec2 describe-instances --region ${region} --filter "Name=tag:Name,Values=*-master-node" --query 'Reservations[].Instances[].PrivateIpAddress' --output text)
IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
cat << EOF > /etc/elasticsearch/elasticsearch.yml
cluster.name: ${cluster_name}
bootstrap.memory_lock: true
node.master: ${node_master}
node.data: true
discovery.zen.ping.unicast.hosts: [`echo $${MASTERS} | tr '\n' ',' | sed 's/,*$//g'`]
network.host: [_local_, $${IP}]
EOF

# Basic checks for Elasticsearch
[[ ! -d /usr/share/elasticsearch/logs ]] && mkdir -p /usr/share/elasticsearch/logs
chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/
service elasticsearch start

# install kibana on first master only
if [[ `echo $${MASTERS} | awk '{print $1}'` == $${IP} ]]; then
  [[ ! -f /etc/init.d/kibana ]] && rpm -i https://artifacts.elastic.co/downloads/kibana/kibana-${elasticsearch_version}-x86_64.rpm
  chkconfig | grep kibana &>/dev/null
  [[ $? -eq 1 ]] && chkconfig --add kibana
  sed -i '/server.port:/s/^#//g' /etc/kibana/kibana.yml
  sed -i '/elasticsearch.url:/s/^#//g' /etc/kibana/kibana.yml
  sed -i 's/#server.host:.*/server.host: "0.0.0.0"/g' /etc/kibana/kibana.yml
  service kibana start
fi
