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
docker inspect ray_tracing_in_vulkan >/dev/null || docker build . \
    -f docker/Dockerfile \
    -t ray_tracing_in_vulkan \
    --compress \
    --rm \
    --build-arg VK_VERSION=$VK_VERSION \
    --build-arg http="$http_proxy" \
    --build-arg https="$https_proxy" \
\
&& mkdir -p ./build_ubuntu20.04/linux/libs/ \
&& docker create --name trow_away_ray_tracing_in_vulkan ray_tracing_in_vulkan \
&& docker cp trow_away_ray_tracing_in_vulkan:/root/depot/build/linux/ ./build_ubuntu20.04/ \
&& docker cp trow_away_ray_tracing_in_vulkan:/lib/x86_64-linux-gnu/libm.so.6 ./build_ubuntu20.04/linux/libs/ \
&& docker cp trow_away_ray_tracing_in_vulkan:/lib/x86_64-linux-gnu/libm-2.31.so ./build_ubuntu20.04/linux/libs/ \
&& docker cp trow_away_ray_tracing_in_vulkan:/lib/x86_64-linux-gnu/libstdc++.so.6 ./build_ubuntu20.04/linux/libs/ \
&& docker cp trow_away_ray_tracing_in_vulkan:/lib/x86_64-linux-gnu/libstdc++.so.6.0.28 ./build_ubuntu20.04/linux/libs/ \
&& docker rm trow_away_ray_tracing_in_vulkan \
&& echo -e "#!/bin/bash\n\ncd \$(dirname \$(readlink -f \$BASH_SOURCE))\nLD_LIBRARY_PATH=\$(pwd)/libs ./bin/RayTracer\n" > ./build_ubuntu20.04/linux/run.sh \
&& chmod a+x ./build_ubuntu20.04/linux/run.sh \
&& echo -e "\n\nSuscessfully build in ./build_ubuntu20.04/\n\n"
ln -s build_ubuntu20.04/linux/run.sh  ./
