#!/bin/bash

version=7.0

gcc=$(which gcc > /dev/null;echo $?)
mk=$(which make > /dev/null;echo $?)
wget=$(which wget > /dev/null;echo $?)

installed=$(snapraid -v |grep ${version})
if [ $? -eq 0 ];
then	
	echo "Looks like version ${version} is already installed, we shouldn't do anything"
else
	echo "Downloading and installing version ${version} of snapraid"

	if [ $gcc -eq 0 ]; 
	
	then
		echo "GCC appears to be installed"
	else
		echo "No sign of GCC, I'll install it."
		install="$install gcc"
	fi

	if [ $mk -eq 0 ];
	then
		echo "Make appears to be installed"
	else
		echo "No sign of Make, I'll need to install it"
		install="$install make"
	fi

	if [ $wget -eq 0 ];
	then
		echo "Wget appears to be installed"
	else
		echo "No sign of wget, I'll need to install it"
		install="$install wget"
	fi

	apt-get install ${install} -qy

	if [ -e snapraid-${version}.tar.gz ];
	then
		echo "Looks like the latest tar file is already downloaded"
	else
		echo "Getting snapraid sourcecode"
		wget http://sourceforge.net/projects/snapraid/files/snapraid-${version}.tar.gz
	fi

	tar xvf snapraid-${version}.tar.gz

##	cd snapraid-${version} && ./configure && make && make check && make install

	echo "Let's cleanup now"

	rm -rf snapraid-${version}
	rm snapraid-${version}.tar.gz

	apt-get remove ${install} -qy
fi
