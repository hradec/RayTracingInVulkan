#!/bin/sh

# the version of vulkan to build with
# it can be overwriten by passing the new one as argument!
VK_VERSION=1.2.162
if [ "$1" != "" ] ; then
    VK_VERSION=$1
fi


docker rm trow_away_ray_tracing_in_vulkan 2>&1 >/dev/null

# build the docker image, which will build
# this depot in Ubuntu.
echo  docker build . \
    -f docker/Dockerfile \
    -t ray_tracing_in_vulkan \
    --compress \
    --rm \
    --build-arg VK_VERSION=$VK_VERSION \
\
&& mkdir -p ./build_ubuntu20.04/ \
&& docker create --name trow_away_ray_tracing_in_vulkan ray_tracing_in_vulkan \
&& docker cp trow_away_ray_tracing_in_vulkan:/root/depot/build/linux/ ./build_ubuntu20.04/ \
&& docker rm trow_away_ray_tracing_in_vulkan \
&& echo -e "\n\nSuscessfully build in ./build/ubuntu20.04/\n\n"
