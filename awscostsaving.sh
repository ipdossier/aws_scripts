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

AWS_CLI='/usr/bin/aws ec2'
DATE=`date +%Y-%m-%d`
LOGDIR='/var/log/nightsleep'
LOG_START_INST=$LOGDIR/startlog.$DATE
LOG_STOP_INST=$LOGDIR/stoplog.$DATE

# checks if log directory exists or not. creates if missing

if [[ ! -d $LOGDIR ]];then
  mkdir -p $LOGDIR
  chmod 700 $LOGDIR
fi

# this function is to collect the instance-id for instances with Key/Value = NightSleep/True

function collect_night_sleep_instances(){

  $AWS_CLI describe-tags --filters "Name=resource-type,Values=instance" "Name=key,Values=NightSleep" "Name=value,Values=True" | grep ResourceId | awk '{print $NF}' | cut -d '"' -f2
  
}

# this function is to start the instance with Key/Value = NightSleep/True

function instance_start(){
  inst_night_sleep=(`collect_night_sleep_instances`)

  for instance_id in "${inst_night_sleep[@]}";do
    echo "## working on instance startup : $instance_id ##" | tee -a $LOG_START_INST
    $AWS_CLI start-instances --instance-id $instance_id | tee -a $LOG_START_INST
  done

}

# this function is to stop the instance with Key/Value = NightSleep/True

function instance_stop(){
  inst_night_sleep=(`collect_night_sleep_instances`)

  for instance_id in "${inst_night_sleep[@]}";do
    echo "## working on instance stop : $instance_id ##" | tee -a $LOG_STOP_INST
    $AWS_CLI stop-instances --instance-id $instance_id | tee -a $LOG_STOP_INST
  done

}

# this function is to check the status of instances with Key/Value = NightSleep/True

function instance_status(){

  inst_night_sleep=(`collect_night_sleep_instances`)

  for instance_id in "${inst_night_sleep[@]}";do
    instance_state=$($AWS_CLI describe-instances --instance-id $instance_id --output text | grep -w STATE | awk '{print $NF}')
    echo "Instance $instance_id is under Night Sleep and Its current state is $instance_state"
  done
}


### Main code

OPTION=$1
case $OPTION in
  start)  instance_start ;;
  stop)   instance_stop ;;
  status) instance_status ;;
  *) echo "Error occurred : valid options are stop/start/status" ;;
esac

exit 0
