#!/usr/bin/env bash
WORKDIR="$( cd "$(dirname "$0")"; pwd -P)"
REGION=us-west-2

function _test(){
  type ${1} &> /dev/null
  [[ $? -ne 0 ]] && echo "${1} not installed... aborting" && exit 1
}

_test aws
_test node
_test npm

[[ ${AWS_ACCESS_KEY_ID} == "" ||
   ${AWS_SECRET_ACCESS_KEY} == "" ]] && echo "Please source your AWS credentials..." && exit 1

echo "Loading AWS settings..."

export AWS_REGION=${REGION}
MASTER=$(aws ec2 describe-instances --region ${REGION} --filter "Name=tag:Name,Values=*-master-node" --query 'Reservations[].Instances[].PublicIpAddress' --output text | head -n 1)
[[ ${MASTER} == "" ]] && echo "Error, no master found... aborting" && exit 1

cd ${WORKDIR}/pipeline
npm install &>/dev/null
HOST=${MASTER} npm start
