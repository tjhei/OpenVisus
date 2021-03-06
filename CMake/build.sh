#!/bin/sh

THIS_DIR=$(dirname $0)
	
if [ $(uname) = "Darwin" ]; then
	$THIS_DIR/build_osx.sh

elif [ -x "$(command -v apt-get)" ]; then
	$THIS_DIR/build_ubuntu.sh

elif [ -x "$(command -v zypper)" ]; then
	$THIS_DIR/build_opensuse.sh
	
elif [ -x "$(command -v yum)" ]; then
	$THIS_DIR/build_manylinux.sh

elif [ -x "$(command -v apk)" ]; then
	$THIS_DIR/build_alpine.sh

else
	echo "Failed to detect OS version"
fi

	

