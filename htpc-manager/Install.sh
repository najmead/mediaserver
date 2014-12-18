#!/bin/bash

############# Set some parameters #############
GROUP="media"
GROUPID="10000"
USER="htpc"
SERVERPORT="8000"
CONFIGDIR="/etc/downloaders/${USER}"
##DATADIR="/media"
###############################################

## Check to see if group exists, if not, create it.
getent group "${GROUP}" > /dev/null
if [ $? -eq 0 ]; then
	echo "Group $GROUP already exists, no need to create."
else
	echo "Group $GROUP does not exist, so creating it..."
	groupadd -g ${GROUPID} ${GROUP}
fi

echo	"Setting up user $USER"

if [ -d "$CONFIGDIR" ]; then
	echo "Directory already exists"
else
	echo "Directory doesn't exist, so creating it..."
	mkdir -p "$CONFIGDIR"
fi

## Check to see if user exists, if not, create it.
getent passwd "${USER}" > /dev/null
if [ $? -eq 0 ]; then
	echo "User $USER already exists, no need to create."
else
	echo "User $USER does not exist, creating it..."
	useradd -u ${SERVERPORT} -g "${GROUP}" -s /usr/bin/nologin -d "$CONFIGDIR" "${USER}"
	chown -R $USER:$GROUP $CONFIGDIR
fi

## Check to  see if image exists, if not, create it
docker images|grep -c "${USER}" > /dev/null
if [ $? -eq 0 ]; then
	echo "Docker image already exists."
else
	echo "Docker image doesn't exist, creating it..."
	echo "Customising Dockerfile"
	cp Dockerfile.tpl Dockerfile
	sed -i s#ENV\ USER\ xxxx#ENV\ USER\ ${USER}# Dockerfile
	sed -i s#ENV\ SERVERPORT\ xxxx#ENV\ SERVERPORT\ ${SERVERPORT}# Dockerfile
	sed -i s#ENV\ CONFIGDIR\ xxxx#ENV\ CONFIGDIR\ ${CONFIGDIR}# Dockerfile
	sed -i s#ENV\ DATADIR\ xxxx#ENV\ DATADIR\ ${DATADIR}# Dockerfile
	sed -i s#ENV\ GROUP\ xxxx#ENV\ GROUP\ ${GROUP}# Dockerfile
	sed -i s#ENV\ GROUPID\ xxxx#ENV\ GROUPID\ ${GROUPID}# Dockerfile

	echo "Setting ENTRYPOINT"
	sed -i s#--datadir=xxxx#--datadir=${CONFIGDIR}# Dockerfile
	sed -i s#--port=xxxx#--port=${SERVERPORT}# Dockerfile

	echo "Building image"
	docker build -t "${USER}" .
fi

## Add systemd file
##if [ -e /etc/systemd/system/${USER}.servicex ]; then
##	echo "Sickbeard service already exists."
##else
##	echo "Adding sickbeard service to systemd."
##	echo "Customising sickbeard.service"
##	cp Service.tpl ${USER}.service
##	sed -i s#ExecStart=xxxx#ExecStart=/usr/bin/docker\ run\ -v\ ${CONFIGDIR}:${CONFIGDIR}\ -v\ ${DATADIR}:${DATADIR}\ -p\ ${SERVERPORT}:${SERVERPORT}\ --name=${USER}\ ${USER}# sickbeard.service
##	sed -i s#ExecStop=xxxx#ExecStop=/usr/bin/docker\ stop\ ${USER}# sickbeard.service
##	echo "Copying file to /etc/systemd/system"
##	cp ${USER}.service /etc/systemd/system/
##	echo "Enabling service on startup.  Run systemctl disable ${USER} to disable."
##	systemctl enable ${USER}
##	echo "Starting service."
##	systemctl start ${USER}
##	echo "Checking status."
##	systemctl status ${USER}
##fi

## Finish
##echo "Congratulations.  Sickbeard should now be installed and configured."
##echo "Please read the file Readme.md for more information."


