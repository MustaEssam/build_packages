#!/usr/bin/env bash
# this script builds a ROS2 packages from source


echo "ROS2 builder => ROS_DISTRO=$ROS_DISTRO ROS_PACKAGE=$ROS_PACKAGE ROS_ROOT=$ROS_ROOT"

set -e
#set -x

apt-get update

export ROS_PACKAGE_PATH=${AMENT_PREFIX_PATH}
# create the ROS_ROOT directory
mkdir -p ${ROS_ROOT}/src
cd ${ROS_ROOT}
rosinstall_generator --deps --rosdistro ${ROS_DISTRO} $ROS_PACKAGE \
    xacro\
    robot_localization\
    nmea_msgs\
> ros2.${ROS_DISTRO}.$ROS_PACKAGE.rosinstall
cat ros2.${ROS_DISTRO}.$ROS_PACKAGE.rosinstall
vcs import src < ros2.${ROS_DISTRO}.$ROS_PACKAGE.rosinstall

SKIP_KEYS="libopencv-dev libopencv-contrib-dev libopencv-imgproc-dev python-opencv python3-opencv"

# install dependencies using rosdep
rosdep init
rosdep update
rosdep install -y \
	--ignore-src \
	--from-paths src \
	--rosdistro ${ROS_DISTRO} \
	--skip-keys "$SKIP_KEYS"

# build it all - for verbose, see https://answers.ros.org/question/363112/how-to-see-compiler-invocation-in-colcon-build
colcon build \
	--merge-install \
	--cmake-args -DCMAKE_BUILD_TYPE=Release 
    
# remove build files
rm -rf ${ROS_ROOT}/src
rm -rf ${ROS_ROOT}/logs
rm -rf ${ROS_ROOT}/build
rm ${ROS_ROOT}/*.rosinstall
    
# cleanup apt   
rm -rf /var/lib/apt/lists/*
apt-get clean