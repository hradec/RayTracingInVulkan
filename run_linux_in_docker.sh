#!/bin/bash

CD=$(readlink -f $(dirname $BASH_SOURCE))

X11=" -v /tmp/.X0-lock:/tmp/.X0-lock:rw -v /tmp/.X11-unix:/tmp/.X11-unix:rw -e QT_X11_NO_MITSHM=1 -e DISPLAY -e XAUTHORITY  "
# if [ "$(which nvidia-smi)" != "" ] ; then
#     X11="$X11 --runtime=nvidia -e NVIDIA_DRIVER_CAPABILITIES=all "
# fi

# instead of using just nvidia custom runtime, we choosed to use the host systems
# GL libraries, by mounting then to the docker image. This way, the docker
# image will use libraries compatible with the host video driver, no matter
# what video driver/manufacturer it is!
# this seems to work fine with NVidia drivers on arch linux!
# need more testing on other distros/video board setups.
# this mode only works if we run the docker container with --privileged!
extra_libs1=$(ldconfig -p | grep libGL | grep -v GLU |  grep x86 | awk  '{print $NF}' | while read p ; do [ "$p" != "" ] && pp=$(readlink -f $p) && echo -v $pp:/lib64/$(basename $p):ro ; done)
if [ "$(which nvidia-smi 2>/dev/null)" != "" ] ; then
    extra_libs2=$(ldconfig -p | grep libnvidia | grep $(nvidia-smi | grep SMI | awk '{print $6}') | grep x86 | awk  '{print "-v "$NF":/lib64/"$1":ro"}')
    if [ -e /opt/cuda ] ; then
        extra_libs3=$(ldconfig -p | grep cuda | grep -v opt | grep x86 | awk  '{print "-v "$NF":/lib64/"$1":ro"}')
        extra_libs4=" -v /opt/cuda:/opt/cuda "
    fi
fi
X11=" $X11 $extra_libs1 $extra_libs2 $extra_libs3 $extra_libs4 "
# X11=" $X11 --volume /run/dbus/system_bus_socket:/run/dbus/system_bus_socket "

# and let X accept connections no matter what
xhost +


# this one liner creates the _uid, _user, _gid and _group env vars, so we can
# pass it on to the docker container.
# as it uses the id command, it should work on any host distro that has id command
eval $(echo $(for n in $(id) ; do echo $n | tr '()' ' ' | egrep 'gid|uid' ; done  | awk -F'=' '{print $2}') | awk '{print "export _uid="$1,"; export _user="$2,"; export _gid="$3,"; export _group="$4}')

# now we can finally run a build!
docker rm -f trow_away_ray_tracing_in_vulkan
docker run -ti \
    --name trow_away_ray_tracing_in_vulkan \
    -v $CD/:/RayTracer/ \
    -e _UID=$_uid \
    -e _USER=$_user \
    -e _GID=$_gid \
    -e _GROUP=$_group \
    -e http_proxy=\"$http_proxy\" \
    -e https_proxy=\"$https_proxy\" \
    $X11 \
ray_tracing_in_vulkan /bin/bash

#
# cmd="docker rm -f pipevfx_make >/dev/null 2>&1 ; \
#     docker pull $build_image ; \
#     docker run --rm $TI \
#     -v $CD/pipeline/tools/:/atomo/pipeline/tools/ \
#     -v $CD/pipeline/libs/:/atomo/pipeline/libs/ \
#     -v $CD/pipeline/build/SConstruct:/atomo/pipeline/build/SConstruct \
#     -v $CD/pipeline/build/.build/:/atomo/pipeline/build/.build/ \
#     -v $CD/docker/run.sh:/run.sh \
#     -v $CD/.root:/atomo/.root \
#     -v $HOME:/home/$USER/ \
#     $APPS_MOUNT \
#     -e _UID=$_uid \
#     -e _USER=$_user \
#     -e _GID=$_gid \
#     -e _GROUP=$_group \
#     -e RUN_SHELL=$SHELL \
#     -e EXTRA=\"$EXTRA\" \
#     -e DEBUG=\"$DEBUG\" \
#     -e TRAVIS=\"$TRAVIS\" \
#     -e http_proxy=\"$http_proxy\" \
#     -e https_proxy=\"$https_proxy\" \
#     $EXTRA_ENVS \
#     -e MEMGB=\"$(grep MemTotal /proc/meminfo | awk '{print $(NF-1)}')\" \
#     $X11 \
#     --network=host \
#     --privileged \
#     $build_image"
#
# echo $cmd
# eval $cmd
#
#
