#!/usr/bin/env bash
# this script builds a ROS2 packages from source

set -e
#set -x

apt-get update

# create the ROS_ROOT directory
mkdir -p ${ROS_ROOT}/src
cd ${ROS_ROOT}
rosinstall_generator --deps --rosdistro iron \
    xacro\
    robot_localization\
    nmea_msgs\
> ros2.iron.pkgs.rosinstall
cat ros2.iron.pkgs.rosinstall
vcs import src < ros2.iron.pkgs.rosinstall

SKIP_KEYS="libopencv-dev libopencv-contrib-dev libopencv-imgproc-dev python-opencv python3-opencv"

# install dependencies using rosdep
rosdep update
rosdep install -y \
	--ignore-src \
	--from-paths src \
	--rosdistro iron \
	--skip-keys "$SKIP_KEYS"

# build it all - for verbose, see https://answers.ros.org/question/363112/how-to-see-compiler-invocation-in-colcon-build
colcon build \
	--merge-install \
	 --base-paths src/
    
# remove build files
rm -rf ${ROS_ROOT}/src
rm -rf ${ROS_ROOT}/logs
rm -rf ${ROS_ROOT}/build
rm ${ROS_ROOT}/*.rosinstall
    
# cleanup apt   
rm -rf /var/lib/apt/lists/*
apt-get clean