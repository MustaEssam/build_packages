#
# Dockerfile for building ROS2 packages from source
#
ARG BASE_IMAGE = zed:r35.4.1-zed
FROM ${BASE_IMAGE}

ARG ROS_PACKAGE=desktop
ARG ROS_VERSION=iron

ENV ROS_DISTRO=${ROS_VERSION}
ENV ROS_ROOT=/opt/ros/${ROS_DISTRO}
ENV ROS_PYTHON_VERSION=3

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL /bin/bash
SHELL ["/bin/bash", "-c"] 

WORKDIR /tmp

# change the locale from POSIX to UTF-8
RUN apt-get update && \
    apt-get install -y --no-install-recommends locales \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV PYTHONIOENCODING=utf-8

# build ROS packages from source
COPY packages_build.sh packages_build.sh
RUN ./packages_build.sh

# commands will be appended/run by the entrypoint which sources the ROS environment
COPY ros_entrypoint.sh /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["/bin/bash"]

WORKDIR /
