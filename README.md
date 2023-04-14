# Ardupilot Gazebo Plugin & Models

| Ubuntu 18.04  | Ubuntu 20.04|
|---------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|
 [![Melodic](https://github.com/larics/ardupilot_gazebo/workflows/Melodic/badge.svg)](https://github.com/larics/ardupilot_gazebo/actions) | [![Noetic](https://github.com/larics/ardupilot_gazebo/workflows/Noetic/badge.svg)](https://github.com/larics/ardupilot_gazebo/actions) |

## Requirements

* Ubuntu 18.04 LTS (Bionic Beaver)
* ROS Melodic
* Gazebo 9
* Zavrsni
* Testiranje Gita i random implementacija izmjena

## Installation

Pleas refer to the [Installation Instruction](INSTALLATION.md).

## Simulation Startup

**Note**: Make sure that you start the *sim_vehicle.py* script for each vehicle from their respective folder.

### Bebop

````bash
# 1st terminal
mkdir -p ~/bebop_startup
cd ~/bebop_startup
sim_vehicle.py -v ArduCopter -f gazebo-iris -m --mav10 --console --map -I0 -m --streamrate=50

# 2nd terminal
roslaunch ardupilot_gazebo bebop.launch

# 3rd terminal
roslaunch ardupilot_gazebo mavros.launch
````

### Ardrone

````bash
# 1st terminal
mkdir -p ~/bebop_startup
cd ~/bebop_startup
sim_vehicle.py -v ArduCopter -f gazebo-iris -m --mav10 --console --map -I0 -m --streamrate=50

# 2nd terminal
roslaunch ardupilot_gazebo ardrone.launch

# 3rd terminal
roslaunch ardupilot_gazebo mavros.launch
````

### Kopterworx

#### SINGLE UAV

````bash
# 1st terminal
roslaunch ardupilot_gazebo sim_vechicle.launch

# 2nd terminal
roslaunch ardupilot_gazebo kopterworx.launch

# 3rd terminal
roslaunch ardupilot_gazebo mavros.launch
````

#### Multiple UAVs

**NOTE**: Every UAV instance needs a unique SYSID_THISMAV parameter. This is taken care of in the *run_copter.sh*.
Furthermore, the target_system parameter needs to increase both in sim_vehicle and mavros.

````bash
  roslaunch gazebo_ros empty_world.launch

  # 2 x sim_vehicle
  roslaunch ardupilot_gazebo sim_vehicle.launch id:=1
  roslaunch ardupilot_gazebo sim_vehicle.launch id:=2

  # 2 x spawn_kopterworx
  roslaunch ardupilot_gazebo spawn_kopterworx.launch name:=red x:=0 y:=0 fdm_port_in:=9002 fdm_port_out:=9003
  roslaunch ardupilot_gazebo spawn_kopterworx.launch name:=blue x:=2 y:=2 fdm_port_in:=9012 fdm_port_out:=9013

  # 2 x start mavros
  roslaunch ardupilot_gazebo mavros.launch namespace:=red
  roslaunch ardupilot_gazebo mavros.launch namespace:=blue fcu_url:="udp://:14560@localhost:14565" tgt_system:=2
````

### 3DR IRIS Copter

````bash
# On 1st Terminal(Launch Ardupilot SITL)
sim_vehicle.py -v ArduCopter -f gazebo-iris  -m --mav10 --map --console -I0

# On 2nd Terminal(Launch Gazebo with demo 3DR Iris model)
gazebo --verbose iris_ardupilot.world
````

### Plane

````bash
# On 1st Terminal(Launch Ardupilot SITL)
sim_vehicle.py -v ArduPlane -f gazebo-zephyr  -m --mav10 --map --console -I0

# On 2nd Terminal(Launch Gazebo with demo Zephyr flying wing model)
gazebo --verbose zephyr_ardupilot_demo.world
````

### Rover

````bash
# On 1st Terminal(Launch Ardupilot SITL)
sim_vehicle.py -v APMrover2 -f gazebo-rover  -m --mav10 --map --console -I1

# On 2nd Termianal(Launch Gazebo with differential drive Rover model, Retrieved from Husky Model)
gazebo --verbose rover_ardupilot.world
````

## Simulation and MAVProxy commands

Various MAVProxy commands can be found in [UAV Configuration - MAVProxy](https://ardupilot.github.io/MAVProxy/html/uav_configuration/index.html).

### Streamrate

In order to enable increased MAVProxy stream rate enter the following in the MavProxy command line.

````bash
set baudrate 921600
set streamrate 50
set streamrate2 50
````

Those commands can be saved to a file called "mavinit.src". They will be automatically executed if you use the following command

````bash
sim_vehicle.py -v ArduCopter -f gazebo-iris -m --aircraft="[absolute path to mavinit.src]" --map --console -I0
````

To increase Mavros topic stream rate enter the following command.

````bash
rosrun mavros mavsys rate --all 50
````

### Takeoff commands

This section concerns UAV simulations.

When messages:

* EKF1 is using GPS
* EKF2 is using GPS

appear then execute the following command in the MAVProxy command line.

```bash
# Set Throttle channel to neutral
rc 3 1500

# Arm and takeoff
mode guided
arm throttle
takeoff 3
```

### AUTOTUNE instructions

In the MAVProxy command line type in the following lines.

```bash
# set Channel 7 to trigger AUTOTUNE mode
param set RC7_OPTION 17

# Set Autotune to tune all axes
param set AUTOTUNE_AXES 7

# Set Channel 7 to LOW value
rc 7 1100

# Set Throttle channel to neutral
rc 3 1500

# Arm and takeoff
mode guided
arm throttle
takeoff 3

# Trigger AUTOTUNE mode
rc 7 1900

# Wait for Autotune to finish...

# Exit and enter AUTOTUNE mode again
rc 7 1100
rc 7 1900

# Land in AUTOTUNE mode and new PARAMETERS should set and saved
rc 3 1400

# Save parameter file
param save ~/catkin_ws/src/ardupilot_gazebo/config/new_params.parm
```

## GCS

In addition, you can use any GCS that can connect to the Ardupilot locally or remotely(will require connection setup).
If MAVProxy Developer GCS is uncomfortable. Omit --map --console arguments out of SITL launch and use APMPlanner2 or QGroundControl instead.

Local connection with APMPlanner2/QGroundControl is automatic, and easier to use.

You will also need to edit ArduPilot Parameter SYSID_THISMAV to be unique from one another for the GCS connection

### APMPlanner2

Download it from [here](http://firmware.eu.ardupilot.org/Tools/APMPlanner/)
and launch it in terminal or run executable

```bash
apmplanner2
```

### QGroundControl

Download it from [here](https://donlakeflyer.gitbooks.io/qgroundcontrol-user-guide/en/download_and_install.html) and follow the installation guide.

## Multi-Vehicle simulation

This section explains how to connect any combination of multi-vehicles of ArduPilot

For the multi-vehicle connection, port number is increased by 10 per instance(#)
In SITL launch argument -I # of sim_vehicle.py 

-I 0 has FDM in/out ports of 9002/9003 / GCS connection UDP:14550

-I 1 has FDM in/out ports of 9012/9013 / GCS connection UDP:14560

-I 2 has FDM in/out ports of 9022/9023 / GCS connection UDP:14570

and so on...

You will need to edit your world for any combination of Rover, Plane, Copter, etc...

### Example
Look simulation of 3 IRIS quadcopter at once from Jonathan Lopes Florêncio
https://www.youtube.com/watch?v=3c7EhVMaqKY&feature=youtu.be

## Troubleshooting

### Missing libArduPilotPlugin.so... etc

In case you see this message when you launch gazebo with demo worlds, check you have no error after sudo make install.  
If no error use "ls" on the install path given to see if the plugin is really here.  
If this is correct, check with "cat /usr/share/gazebo/setup.sh" the variable GAZEBO_PLUGIN_PATH. It should be the same as the install path. If not use "cp" to copy the lib to right path.

**For Example**

````
sudo cp -a /usr/lib/x86_64-linux-gnu/gazebo-7.0/plugins/ /usr/lib/x86_64-linux-gnu/gazebo-7/
````

Path mismatch is confirmed as ROS's glitch. It only happens with Gazebo 7
