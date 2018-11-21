#!/bin/bash

. "$(dirname "$0")/build_common.sh"

DOCKER_IMAGE=${DOCKER_IMAGE:-ubuntu:trusty} 

# see build_common.sh to see what you want to 'forward'
PushDockerEnvs

chmod +x CMake/build*.sh
sudo docker run --name mydocker -d -t -v ${SOURCE_DIR}:/home/OpenVisus ${docker_opts} ${DOCKER_IMAGE} /bin/bash
sudo docker exec -ti   mydocker /bin/bash -c "cd /home/OpenVisus && ./CMake/build.sh"

# fix permissions
sudo chown -R "$USER":"$USER" ${BUILD_DIR}
sudo chmod -R u+rwx           ${BUILD_DIR}

