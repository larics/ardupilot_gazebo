#!/bin/bash
# Sets the ODE solver iterations of the Gazebo world once it is up, checks them, and unpauses.
# With Gazebo's default of 50, a multirotor resting on the ground can settle into a contact
# jitter that the IMU reads as a steady ~0.5 deg/s. The autopilot calibrates that away as gyro
# bias at boot, flies with a tilted attitude estimate and drifts on takeoff. 200 removes it at
# real-time factor 1.
#   set_physics_iters.sh <iterations>
ITERS=${1:-200}
# Gazebo starts paused (kopterworx.launch) so nothing settles with the old solver; whatever
# happens here, it runs afterwards.
trap 'rosservice call /gazebo/unpause_physics > /dev/null 2>&1' EXIT
for i in $(seq 1 240); do
  if rosservice call /gazebo/get_physics_properties > /dev/null 2>&1; then
    gz physics -i "$ITERS" > /dev/null 2>&1
    GOT=$(rosservice call /gazebo/get_physics_properties 2>/dev/null | awk '/sor_pgs_iters/ {print $2}')
    if [ "$GOT" == "$ITERS" ]; then
      echo "[set_physics_iters] ODE solver iterations $ITERS"
      exit 0
    fi
  fi
  sleep 0.5
done
echo "[set_physics_iters] could not set the ODE solver iterations within 120 s" >&2
exit 1
