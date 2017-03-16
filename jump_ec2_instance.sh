#!/bin/bash
if [ "$#" = "0" ];then
  echo "Usage $0 <instance name> <command>" 
  exit 1
fi
name=$1
command=$2
ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${name}" | jq '.Reservations[] | .Instances[] | .PublicIpAddress' | tail -n1 | sed -e 's/"//g')

if [ ! -z "${ip}" ];then
  echo "Connect to the IP: ${ip}"
  ssh -p22 -i /root/.ssh/dossier_keypair.pem ec2-user@${ip} -t "${command}"
else
  echo "Could not found ${name} server"
fi
