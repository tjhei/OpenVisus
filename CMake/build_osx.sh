#!/bin/bash

set -ex 

PYTHON_VERSION=${PYTHON_VERSION:-3.6.5} 
CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-Release} 
VISUS_INTERNAL_DEFAULT=${VISUS_INTERNAL_DEFAULT:-0} 
VISUS_GUI=${VISUS_GUI:-1}  
BUILD_DIR=${BUILD_DIR:-/tmp/OpenVisus/build}
DEPLOY_PYPI=${DEPLOY_PYPI:0}

# //////////////////////////////////////////////////////
function DownloadFile {
	curl -fsSL --insecure "$1" -O
}

# //////////////////////////////////////////////////////
function PushCMakeOption {
	if [ -n "$2" ] ; then
		cmake_opts+=" -D$1=$2"
	fi
}

# //////////////////////////////////////////////////////
function InstallBrew {

	if [ -x "$(command -v brew)" ]; then
		return
	fi
	
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew update >/dev/null || true
}


# //////////////////////////////////////////////////////
function InstallPython {

	brew install pyenv || true
	brew upgrade pyenv || true
	eval "$(pyenv init -)"
	eval "$(pyenv virtualenv-init -)"
	# pyenv install --list    
		
	if [ "${PYTHON_VERSION:0:1}" -gt "2" ]; then
		PYTHON_M_VERSION=${PYTHON_VERSION:0:3}m 
	else
		PYTHON_M_VERSION=${PYTHON_VERSION:0:3}
	fi	
  
	export PYTHON_EXECUTABLE=$(pyenv prefix)/bin/python 
	export PYTHON_INCLUDE_DIR=$(pyenv prefix)/include/python${PYTHON_M_VERSION} 
	export PYTHON_LIBRARY=$(pyenv prefix)/lib/libpython${PYTHON_M_VERSION}.so
}


# //////////////////////////////////////////////////////
function InstallQt {
	brew install qt5
	Qt5_DIR=$(brew --prefix Qt)/lib/cmake/Qt5	
}


InstallBrew            
InstallPython

# this is to solve logs too long 
gem install xcpretty   

brew install swig  
if (( VISUS_INTERNAL_DEFAULT==0 )); then 
  brew install zlib lz4 tinyxml freeimage openssl curl
fi

if (( VISUS_GUI==1 )); then
	InstallQt
fi

cmake_opts=""
cmake_opts+=" -GXcode"
PushCMakeOption PYTHON_VERSION         ${PYTHON_VERSION}
PushCMakeOption CMAKE_BUILD_TYPE       ${CMAKE_BUILD_TYPE}
PushCMakeOption VISUS_INTERNAL_DEFAULT ${VISUS_INTERNAL_DEFAULT}
PushCMakeOption VISUS_GUI              ${VISUS_GUI}
PushCMakeOption PYTHON_EXECUTABLE      ${PYTHON_EXECUTABLE}
PushCMakeOption PYTHON_INCLUDE_DIR     ${PYTHON_INCLUDE_DIR}
PushCMakeOption PYTHON_LIBRARY         ${PYTHON_LIBRARY}
PushCMakeOption Qt5_DIR                ${Qt5_DIR}

SOURCE_DIR=$(pwd)
mkdir -p $BUILD_DIR
cd $BUILD_DIR
cmake ${cmake_opts} ${SOURCE_DIR} 

set -o pipefail && \
cmake --build ./ --target ALL_BUILD   --config ${CMAKE_BUILD_TYPE} | xcpretty -c
cmake --build ./ --target RUN_TESTS   --config ${CMAKE_BUILD_TYPE}
cmake --build ./ --target install     --config ${CMAKE_BUILD_TYPE}  
cmake --build ./ --target deploy      --config ${CMAKE_BUILD_TYPE} 
cmake --build ./ --target bdist_wheel --config ${CMAKE_BUILD_TYPE} 
cmake --build ./ --target sdist       --config ${CMAKE_BUILD_TYPE} 

if ((DEPLOY_PYPI==1)); then 
	cmake --build ./ --target pypi      --config ${CMAKE_BUILD_TYPE}
fi

cd install
PYTHONPATH=$(pwd)           ./visus                       && echo "Embedding working"      
PYTHONPATH=$(pwd):$(pwd)/bin python -c "import OpenVisus" && echo "Extendig working"







