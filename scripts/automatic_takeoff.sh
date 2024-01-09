#!/bin/bash

# Exit immediatelly if a command exits with a non-zero status
set -e

# Executes a command when DEBUG signal is emitted in this script - should be after every line
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# Executes a command when ERR signal is emmitted in this script
trap 'echo "$0: \"${last_command}\" command failed with exit code $?"' ERR

TAKEOFF_HEIGHT=$1
if [ -z "${TAKEOFF_HEIGHT}" ] ; then
  TAKEOFF_HEIGHT=2
fi

ODOMETRY_TOPIC=$2
if [ -z "${ODOMETRY_TOPIC}" ] ; then
  ODOMETRY_TOPIC=mavros/global_position/local
fi

WAITFORSIM=$3
if [ -z "${WAITFORSIM}" ] ; then 
  WAITFORSIM="true"
fi

# get the path to this script
MY_PATH=`dirname "$0"`
MY_PATH=`( cd "$MY_PATH" && pwd )`
source $MY_PATH/shell_scripts.sh

# Automatic takeoff
echo "Automatic takeoff started for $UAV_NAMESPACE UAV"
waitForRos

if [ "$WAITFORSIM" == "true" ] ; then
  waitForSimulation
fi

if [ "$ODOMETRY_TOPIC" == "mavros/global_position/local" ] ; then
  waitForOdometry
fi

echo "UAV $UAV_NAMESPACE switch to GUIDED_NOGPS mode"
rosservice call /$UAV_NAMESPACE/mavros/set_mode 0 GUIDED_NOGPS >> /dev/null 2>&1
waitForCarrot

echo "UAV $UAV_NAMESPACE switch controller to CARROT"
rostopic pub --once /$UAV_NAMESPACE/joy sensor_msgs/Joy "buttons: [0,0,0,0,0,1]" >> /dev/null 2>&1

echo "Arming UAV $UAV_NAMESPACE" 
rosservice call /$UAV_NAMESPACE/mavros/cmd/arming true >> /dev/null 2>&1

sleep 2
echo "UAV $UAV_NAMESPACE takeoff"
rosservice call /$UAV_NAMESPACE/takeoff $TAKEOFF_HEIGHT >> /dev/null 2>&1
