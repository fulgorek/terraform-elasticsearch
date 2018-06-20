#!/usr/bin/env bash
WORKDIR="$( cd "$(dirname "$0")"; pwd -P)"
REGION=${1:-us-west-2}

function _test(){
  type ${1} &> /dev/null
  [[ $? -ne 0 ]] && echo "${1} not installed... aborting" && exit 1
}

_test terraform
_test aws

[[ ${AWS_ACCESS_KEY_ID} == "" ||
   ${AWS_SECRET_ACCESS_KEY} == "" ]] && echo "Please source your AWS credentials..." && exit 1

echo "Loading AWS settings..."

export AWS_REGION=${REGION}
VPC_DATA=$(aws ec2 describe-vpcs --region ${REGION} --query 'Vpcs[?IsDefault==`true`].[VpcId,CidrBlock]' --output text)
DEFAULT_VPC=`echo ${VPC_DATA} | awk '{print $1}'`
DEFAULT_CIDR=`echo ${VPC_DATA} | awk '{print $2}'`
SUBNETS=$(aws ec2 describe-subnets --region ${REGION} --filters "Name=vpc-id,Values=${DEFAULT_VPC}" --query 'Subnets[*].SubnetId' --output text | sed 's/\t/,/g')

export TF_VAR_vpc_id=${DEFAULT_VPC}
export TF_VAR_master_node_subnets=${SUBNETS}
export TF_VAR_data_node_subnets=${SUBNETS}

echo "Checking Infra changes..."
cd ${WORKDIR}/terraform
terraform init &>/dev/null
CHANGES=$(terraform plan -out=single.plan | grep 'No changes')
if [[ ${CHANGES} == "" ]]; then
  echo "Applying Infra changes..."
  terraform apply "single.plan"
  [[ -f "single.plan" ]] && rm -f single.plan
fi
MASTER=$(aws ec2 describe-instances --region ${REGION} --filter "Name=tag:Name,Values=*-master-node" --query 'Reservations[].Instances[].PublicIpAddress' --output text | head -n 1)

[[ ${MASTER} != "" ]] && echo "Your master: ${MASTER}"
