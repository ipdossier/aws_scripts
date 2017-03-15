#!/bin/bash
if [ "$#" = "0" ];then
  echo "Usage $0 <instance name> <public or private>" 
  exit 1
fi
name=$1
type=${2:-"public"}
if [ "${type}" = "public" ];then
  ips=($(aws ec2 describe-instances --filters "Name=tag:Name,Values=${name}" | jq '.Reservations[] | .Instances[] | .PublicIpAddress' | grep -v "nil\|null" | sed -e 's/"//g'))
else
  ips=($(aws ec2 describe-instances --filters "Name=tag:Name,Values=${name}" | jq '.Reservations[] | .Instances[] | .PrivateIpAddress' | grep -v "nil\|null" | sed -e 's/"//g'))
fi
echo ${ips[@]}


