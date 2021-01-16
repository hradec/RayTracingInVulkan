FROM ubuntu:20.04

ARG VK_VERSION=1.2.162
ENV VK_SDK_VERSION=${VK_VERSION}

RUN echo "VK_SDK_VERSION=$VK_SDK_VERSION"

# install some basic tools needed to continue
RUN apt update
RUN apt install -y wget gnupg sudo curl zip unzip tar

# install the Lunarg ubuntu depot
RUN wget -qO - http://packages.lunarg.com/lunarg-signing-key-pub.asc | apt-key add -
RUN wget -qO /etc/apt/sources.list.d/lunarg-vulkan-${VK_SDK_VERSION}-focal.list http://packages.lunarg.com/vulkan/${VK_SDK_VERSION}/lunarg-vulkan-${VK_SDK_VERSION}-focal.list

# then we install the vulkan sdk
RUN apt update
RUN apt install -y vulkan-sdk

# install git, gcc, make/cmake to be able to build stuff
RUN apt install -y git build-essential cmake

# Libraries needed to build
RUN apt install -y libglfw3-dev
RUN apt install -y libboost-all-dev
RUN apt install -y libglm-dev
# imgui library is packed inside these packages in ubuntu
RUN apt install -y libxi-dev libxinerama-dev libxcursor-dev

# now we add this git depot into /root/build
ADD . /root/depot

# and now we can build vcpkg in linux
RUN cd /root/depot && ./vcpkg_linux.sh

# finally, we can build what we really want!
RUN cd /root/depot && ./build_linux.sh
