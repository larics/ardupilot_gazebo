#!/bin/bash
# Script for launch sim_vehicle.py with all necessary arguments.

# Exit immediatelly if a command exits with a non-zero status
set -e

set -x

# Executes a command when DEBUG signal is emitted in this script - should be after every line
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# Executes a command when ERR signal is emmitted in this script
trap 'echo "$0: \"${last_command}\" command failed with exit code $?"' ERR

# Catch all the bash script arguments
VEHICLE_NAME=$1
VEHICLE_ID=$2
PARAM_PATH=$3
ENABLE_CONSOLE=$4
ENABLE_MAP=$5
STREAMRATE=$6
FRAME=$7
BINARY=$8
DEBUG=$9

# Get valid additional arguments
ADDITIONAL_ARGS=""
for arg in "${@:10:99}"
do
  if [[ ! $arg = __* ]]; then
    echo "[run_copter.sh] Found valid argument: $arg"
    ADDITIONAL_ARGS="${ADDITIONAL_ARGS} ${arg}"
  fi
done

if [ -z "${VEHICLE_NAME}" ] ; then
  VEHICLE_NAME="default"
fi

if [ -z "${VEHICLE_ID}" ] ; then
  VEHICLE_ID="1"
fi

if [ -z "${ENABLE_CONSOLE}" ] ; then
  ENABLE_CONSOLE="true"
fi

if [ -z "${ENABLE_MAP}" ] ; then
  ENABLE_MAP="false"
fi

if [ -z "${STREAMRATE}" ] ; then
  STREAMRATE="50"
fi

if [ -z "${FRAME}" ] ; then
  FRAME="gazebo-iris"
fi

if [ -z "${BINARY}" ]; then
  BINARY="ArduCopter"
fi

DEBUG_ARGS="-D -G"
if [ "${DEBUG}" = false ]; then
  DEBUG_ARGS=""
fi

# Navigate to the startup folder
STARTUP_DIR="$HOME/Documents/${VEHICLE_NAME}_${VEHICLE_ID}_startup"
mkdir -p $STARTUP_DIR
cd $STARTUP_DIR
echo $STARTUP_DIR

SIM_VEHICLE_ARGS=""
if [ "$ENABLE_CONSOLE" = true ] ; then
    SIM_VEHICLE_ARGS="${SIM_VEHICLE_ARGS} --console"
fi
if [ "$ENABLE_MAP" = true ] ; then
    SIM_VEHICLE_ARGS="${SIM_VEHICLE_ARGS} --map"
fi
SIM_VEHICLE_ARGS="${SIM_VEHICLE_ARGS} ${ADDITIONAL_ARGS}"

IDENTITY_PATH=${STARTUP_DIR}/identity.parm
cat <<EOF > ${STARTUP_DIR}/identity.parm
SYSID_THISMAV ${VEHICLE_ID}
EOF


cat ${PARAM_PATH} >> ${IDENTITY_PATH}
echo "sim_vehicle.py ${DEBUG_ARGS} -v ${BINARY} --add-param-file=${IDENTITY_PATH} -f ${FRAME} -I$((${VEHICLE_ID} - 1)) -m \"--mav10 --streamrate=${STREAMRATE} --target-system=${VEHICLE_ID}\" ${SIM_VEHICLE_ARGS}"
sim_vehicle.py  ${DEBUG_ARGS} -v ${BINARY} --add-param-file=${IDENTITY_PATH} -f ${FRAME} -I$((${VEHICLE_ID} - 1)) -m "--mav10 --streamrate=${STREAMRATE} --target-system=${VEHICLE_ID}" ${SIM_VEHICLE_ARGS}
