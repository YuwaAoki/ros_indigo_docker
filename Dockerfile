FROM ubuntu:16.04

RUN apt update \
  && apt install -y --no-install-recommends \
     locales \
     software-properties-common tzdata \
  && locale-gen en_US en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
  && add-apt-repository universe

ENV LANG en_US.UTF-8
ENV TZ=Asia/Tokyo

#Install ROS kinetic
RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
    && sudo apt install curl \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add - \
    && sudo apt-get update \
    && sudo apt-get install ros-kinetic-desktop-full  \ 
    && echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
    && source ~/.bashrc
    && sudo apt install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential \
    && sudo apt install python-rosdep \
    && sudo rosdep init \
    && rosdep update

#Install python-catkin-tools
RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list' \
    && wget http://packages.ros.org/ros.key -O - | sudo apt-key add - \
    && sudo apt-get update \
    && sudo apt-get install python-catkin-tools

#Install velodyne 
RUN sudo apt-get install ros-kinetic-velodyne

#Install pcl
RUN sudo apt-get install ros-kinetic-perception-pcl

#Rosdep
RUN cd /ros_kinetic_ws/src \
    && rosdep install --from-paths . --ignore-src --rosdistro $ROS_DISTRO -y

# Add user and group
ARG UID
ARG GID
ARG USER_NAME
ARG GROUP_NAME

RUN groupadd -g ${GID} ${GROUP_NAME}
RUN useradd -u ${UID} -g ${GID} -s /bin/bash -m ${USER_NAME}

USER ${USER_NAME}

WORKDIR /ros_kinetic_ws

CMD ["/bin/bash"]