#!/bin/bash

############# Set some parameters #############
GROUP="media"
GROUPID="10000"
USER="sonarr"
SERVERPORT="9001"
URLBASE="sonarr"
CONFIGDIR="/etc/downloaders/${USER}"
DATADIR="/media"
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
	echo "User ${USER} already exists, no need to create."
else
	echo "User ${USER} does not exist, creating it..."
	useradd -u ${SERVERPORT} -g "${GROUP}" -s /usr/bin/nologin -d "${CONFIGDIR}" "${USER}"
	chown -R ${USER}:${GROUP} ${CONFIGDIR}
fi

## Check to  see if image exists, if not, create it
docker images|grep -c "${USER}" > /dev/null
if [ $? -eq 0 ]; then
	echo "Docker image already exists."
else
	echo "Docker image doesn't exist, creating it..."
	echo "Customising Dockerfile"
	cp Dockerfile.tpl Dockerfile
	echo "Configuring environment variables."
	sed -i s#ENV\ USER\ xxxx#ENV\ USER\ ${USER}# Dockerfile
	sed -i s#ENV\ SERVERPORT\ xxxx#ENV\ SERVERPORT\ ${SERVERPORT}# Dockerfile
	sed -i s#ENV\ CONFIGDIR\ xxxx#ENV\ CONFIGDIR\ ${CONFIGDIR}# Dockerfile
	sed -i s#ENV\ DATADIR\ xxxx#ENV\ DATADIR\ ${DATADIR}# Dockerfile
	sed -i s#ENV\ GROUP\ xxxx#ENV\ GROUP\ ${GROUP}# Dockerfile
	sed -i s#ENV\ GROUPID\ xxxx#ENV\ GROUPID\ ${GROUPID}# Dockerfile

	echo "Customising ENTRYPOINT"
	sed -i s#-data=xxxx#-datadir=${CONFIGDIR}# Dockerfile
	
	echo "Building image"
	docker build -t "${USER}" .
fi

## Customise config for port
if [  -e ${CONFIGDIR}/.config/NzbDrone/config.xml ]; then
	echo "Config already exists in ${CONFIGDIR}/.config/NzbDrone/config.xml so I won't touch it.  Double check that the port in the config matches the specified port ${SERVERPORT}"
else
	TEMP_CONT=$RANDOM
	echo "Running ${USER} in a temporary container ( ${TEMP_CONT} ) for the first time to generate configs."
	docker run -d -v ${CONFIGDIR}:${CONFIGDIR} --name=${TEMP_CONT} ${USER}
	echo "Let's have a little snooze, to give ${USER} time to setup."
	sleep 10
	echo "Ok, now let's stop the temporary container ( ${TEMP_CONT} )"
	docker stop ${TEMP_CONT}
	echo "Replace the default port with ${SERVERPORT}."
	sed -i s#\<Port\>8989#\<Port\>${SERVERPORT}# ${CONFIGDIR}/.config/NzbDrone/config.xml 
	sed -i s#\<UrlBase\>#\<UrlBase\>${URLBASE}# ${CONFIGDIR}/.config/NzbDrone/config.xml
	echo "Snooze a little bit more"
	sleep 10
fi

## Add systemd file
if [ -e /etc/systemd/system/${USER}.service ]; then
	echo "Service for ${USER} already exists."
else
	echo "Adding ${USER} service to systemd."
	echo "Customising ${USER}.service"
	cp Service.tpl ${USER}.service
	sed -i s#Description=xxxx#Description=${USER}# ${USER}.service
	sed -i s#ExecStart=xxxx#ExecStart=/usr/bin/docker\ run\ -v\ ${CONFIGDIR}:${CONFIGDIR}\ -v\ ${DATADIR}:${DATADIR}\ -p\ ${SERVERPORT}:${SERVERPORT}\ --name=${USER}\ ${USER}# ${USER}.service
	sed -i s#stop\ xxxx#stop\ ${USER}#g ${USER}.service
	sed -i s#rm\ xxxx#rm\ ${USER}#g ${USER}.service
	echo "Copying file to /etc/systemd/system"
	cp ${USER}.service /etc/systemd/system/
	echo "Enabling service on startup.  Run systemctl disable ${USER} to disable."
	systemctl enable ${USER}
	echo "Starting service."
	systemctl start ${USER}
	echo "Checking status."
	systemctl status ${USER}
fi

## Finish
echo "Congratulations  You should now have ${USER} installed and configured."
echo "Please read the file Readme.md for more information."

