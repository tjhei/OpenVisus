FROM quay.io/pypa/manylinux1_x86_64

ARG PYTHON_VERSION=3.6.6
ARG GIT_BRANCH=master   
ARG VISUS_GUI=1

ADD https://api.github.com/repos/sci-visus/OpenVisus/git/refs/heads/$GIT_BRANCH version.json
RUN git clone -b${GIT_BRANCH} https://github.com/sci-visus/OpenVisus.git /home/OpenVisus

WORKDIR /home/OpenVisus  
RUN chmod +x ./CMake/build*.sh 
RUN ./CMake/build.sh

