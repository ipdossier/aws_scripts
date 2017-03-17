#!/bin/bash
#
# this script is written for demo purposes only, script covers the below
# 1) checks if instance have "Key - NightSleep" and its Value. (possible values are "True/False"
# 2) when script called with option "start" - script starts all instances with "Key/Value" = "NightSleep/True"
# 3) when script called with option "stop" -script stops all instances with "Key/Value" = "NightSleep/True"
#
# if instance, does not have "Key/Value" = "NightSleep/True", this script will do NOTHING.
#
# As mentioned, this script is for demo. Use at your own risk. Yogesh Kumar - 27/01/2017

# variable definitions

declare -r DATE=`date +%Y-%m-%d`
declare -r LOGDIR='/var/log/nightsleep'
declare -r LOG_START_INST=$LOGDIR/startlog.$DATE
declare -r LOG_STOP_INST=$LOGDIR/stoplog.$DATE
declare -r TAG_KEY="application"
declare TAG_VALUE=""

# checks if log directory exists or not. creates if missing

if [[ ! -d $LOGDIR ]];then
  mkdir -p $LOGDIR
  chmod 700 $LOGDIR
fi

# this function is to collect the instance-id for instances with Key/Value = NightSleep/True

function collect_instances(){
  [ "x${TAG_VALUE}" = "x" ] && echo ""

  /root/bin/aws ec2 describe-tags --filters "Name=resource-type,Values=instance" "Name=key,Values=${TAG_KEY}" "Name=value,Values=${TAG_VALUE}" | grep ResourceId | awk '{print $NF}' | cut -d '"' -f2
  
}

# this function is to start the instance with Key/Value = NightSleep/True

function instance_start(){
  local -a instances=(`collect_instances`)

  for instance_id in "${instances[@]}";do
    echo "## working on instance startup : $instance_id ##" | tee -a $LOG_START_INST
    /root/bin/aws ec2 start-instances --instance-id $instance_id | tee -a $LOG_START_INST
  done

}

# this function is to stop the instance with Key/Value = NightSleep/True

function instance_stop(){
  instances=(`collect_instances`)

  for instance_id in "${instances[@]}";do
    echo "## working on instance stop : $instance_id ##" | tee -a $LOG_STOP_INST
    /root/bin/aws ec2 stop-instances --instance-id $instance_id | tee -a $LOG_STOP_INST
  done

}

# this function is to check the status of instances with Key/Value = NightSleep/True

function instance_status(){
  instances=(`collect_instances`)
  for instance_id in "${instances[@]}";do
    instance_info=$(/root/bin/aws ec2 describe-instances --instance-id $instance_id --output text)
    while read line;do
#    while read -r line;do
      if [[ "${line}" =~ ^STATE ]];then
        instance_state=$(echo "${line}" | awk '{print $NF}')
      fi
      if [[ "${line}" =~ ^TAGS.+Name ]];then
        instance_name=$(echo "${line}" | awk '{print $NF}')
      fi
    done <<< "${instance_info[@]}"
    echo "${instance_name} (${instance_id}) : $instance_state"
  done
}

function usage(){
  echo "Usage: ${0} <Option> <Application>" 2>&1 
  echo 2>&1
  echo "Options: " 2>&1
  echo "        stop/start/status" 2>&1
  echo "Application : " 2>&1
  echo "         postgresql/zookeeper/apache/r/solr" 2>&1
  echo 2>&1
}
### Main code

OPTION=$1

[ "x${2}" = "x" ] && { usage; exit 1; }
TAG_VALUE=$2

case $OPTION in
  start)  instance_start ;;
  stop)   instance_stop ;;
  status) instance_status ;;
  *) echo "Error occurred : valid options are stop/start/status" ;;
esac

exit 0

