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

function COLLECT_NIGHT_SLEEP_INSTANCES(){

  $AWS_CLI describe-tags --filters "Name=resource-type,Values=instance" "Name=key,Values=NightSleep" "Name=value,Values=True" | grep ResourceId | awk '{print $NF}' | cut -d '"' -f2
  
}

# this function is to start the instance with Key/Value = NightSleep/True

function INSTANCE_START(){
  INST_NIGHT_SLEEP=(`COLLECT_NIGHT_SLEEP_INSTANCES`)

  for INSTANCE_ID in "${INST_NIGHT_SLEEP[@]}";do
    echo "## working on instance startup : $INSTANCE_ID ##" | tee -a $LOG_START_INST
    $AWS_CLI start-instances --instance-id $INSTANCE_ID | tee -a $LOG_START_INST
  done

}

# this function is to stop the instance with Key/Value = NightSleep/True

function INSTANCE_STOP(){
  INST_NIGHT_SLEEP=(`COLLECT_NIGHT_SLEEP_INSTANCES`)

  for INSTANCE_ID in "${INST_NIGHT_SLEEP[@]}";do
    echo "## working on instance stop : $INSTANCE_ID ##" | tee -a $LOG_STOP_INST
    $AWS_CLI stop-instances --instance-id $INSTANCE_ID | tee -a $LOG_STOP_INST
  done

}

# this function is to check the status of instances with Key/Value = NightSleep/True

function INSTANCE_STATUS(){

  INST_NIGHT_SLEEP=(`COLLECT_NIGHT_SLEEP_INSTANCES`)

  for INSTANCE_ID in "${INST_NIGHT_SLEEP[@]}";do
    INSTANCE_STATE=$($AWS_CLI descripbe-instances --instance-id $INSTANCE_ID --output test | grep -w STATE | awk '{print $NF}')
    echo "Instance $INSTANCE_ID is under Night Sleep and Its current state is $INSTANCE_STATE"
  done
}


### Main code

OPTION=$1
case $OPTION in
  start)  INSTANCE_START ;;
  stop)  INSTANCE_STOP ;;
  status) INSTANCE_STATUS ;;
  *) echo "Error occurred : valid options are stop/start/status" ;;
esac

exit 0
