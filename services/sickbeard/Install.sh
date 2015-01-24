#!/bin/bash

############# Set some parameters #############
GROUP="media"
GROUPID="10000"
USER="sickbeard"
SICKBEARDPORT="9000"
URLBASE="sickbeard"
CONFIGDIR="/etc/downloaders/${USER}"
DATADIR="/media"
###############################################

## Check to see if group exists, if not, create it.
getent group "${GROUP}" > /dev/null
if [ $? -eq 0 ]; then
	GROUPID="$(getent group ${GROUP} | cut -d: -f3)"
	echo "Group $GROUP with gid ${GROUPID} already exists, no need to create."
else
	echo "Group $GROUP does not exist, so creating it..."
	groupadd -r ${GROUP}
	GROUPDID="$(getent group ${GROUP} | cut -d: -f3)"
fi

echo	"Setting up user $USER"
getent passwd "${USER}" > /dev/null
if [ $? -eq 0 ]; then
	USERID="$(id -u ${USER})"
	echo "User $USER with uid ${USERID} already exists, no need to create."

else
	echo "User $USER does not exist, creating it..."
	useradd -r -g "${GROUP}" -s /usr/bin/nologin -d "$CONFIGDIR" "${USER}"
	USERID="$(id -u ${USER})"
fi

if [ -d "$CONFIGDIR" ]; then
	echo "Directory already exists, making sure it has the correct permissions."
	chown -R $USER:$GROUP $CONFIGDIR
else
	echo "Directory doesn't exist, so creating it..."
	mkdir -p "$CONFIGDIR"
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
	sed -i s#ENV\ USERID\ xxxx#ENV\ USERID\ ${USERID}# Dockerfile
	sed -i s#ENV\ SICKBEARDPORT\ xxxx#ENV\ SICKBEARDPORT\ ${SICKBEARDPORT}# Dockerfile
	sed -i s#ENV\ CONFIGDIR\ xxxx#ENV\ CONFIGDIR\ ${CONFIGDIR}# Dockerfile
	sed -i s#ENV\ DATADIR\ xxxx#ENV\ DATADIR\ ${DATADIR}# Dockerfile
	sed -i s#ENV\ GROUP\ xxxx#ENV\ GROUP\ ${GROUP}# Dockerfile
	sed -i s#ENV\ GROUPID\ xxxx#ENV\ GROUPID\ ${GROUPID}# Dockerfile

	echo "Building image"
	docker build -t "${USER}" .
fi

if [ -e ${CONFIGDIR}/config.ini ]; then
	echo "Config file already exists.  Double check that the port listed in the config matches specified port, ${SICKBEARPORT}."
else
	TEMP_CONT=$RANDOM
	echo "Running ${USER} in a temporary container ( ${TEMP_CONT} ) for the first time to generate"
	docker run -d -v ${CONFIGDIR}:${CONFIGDIR} --name=${TEMP_CONT} ${USER}
	echo "Snooze for a moment, to give ${USER} time to setup."
	sleep 10
	echo "Ok, now let's stop the temporary container ( ${TEMP_CONT} )"
	docker stop ${TEMP_CONT}
	echo "Snooze a little bit more"
	sleep 5
	docker rm ${TEMP_CONT}
	if [ -e ${CONFIGDIR}/config.ini ]; then
		echo "Replace the default port with ${SICKBEARDPORT}."
		sed -i s#web_port\ =\ 8081#web_port\ =\ ${SICKBEARDPORT}# ${CONFIGDIR}/config.ini
		sed -i s#web_root\ =\ \"\"#web_root\ =\ \"\/${URLBASE}\"# ${CONFIGDIR}/config.ini
	else
		echo "Running temporarily hasn't generated a config.  I'll just inject data instead."
		echo "[General]" >> ${CONFIGDIR}/config.ini
		echo "web_port = ${SICKBEARDPORT}" >> ${CONFIGDIR}/config.ini
		echo "web_root = /${URLBASE}" >> ${CONFIGDIR}/config.ini
		chown ${USER}:${GROUP} ${CONFIGDIR}/config.ini
	fi
fi

if [ $(ps -p 1 -o comm=) == "systemd" ];
then
	echo "Looks like you are running systemd, I'll try and create a service."

	## Add systemd file
	if [ -e /etc/systemd/system/${USER}.service ]; then
		echo "Service for ${USER} already exists."
	else
		echo "Adding ${USER} service to systemd."
		echo "Customising ${USER}.service"
		cp Service.tpl ${USER}.service
		sed -i s#Description=xxxx#Description=${USER}# ${USER}.service
		sed -i s#ExecStart=xxxx#ExecStart=/usr/bin/docker\ run\ -v\ ${CONFIGDIR}:${CONFIGDIR}\ -v\ ${DATADIR}:${DATADIR}\ -v\ \/etc\/localtime:\/etc\/localtime:ro\ -p\ ${SICKBEARDPORT}:${SICKBEARDPORT}\ --name=${USER}\ ${USER}# ${USER}.service
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
else
	echo "Not using systemd, I'll just run the container directly"
	docker ps -a|grep -c "${USER}" > /dev/null
	if [ $? -eq 0 ];
	then
		echo "Looks like there is a container called ${USER} already.  I won't touch it"
	else
		docker run -v ${CONFIGDIR}:${CONFIGDIR} -v ${DATADIR}:${DATADIR} -v /etc/localtime:/etc/localtime:ro -p ${SICKBEARDPORT}:${SICKBEARDPORT} --name=${USER} -d --restart=always ${USER}
	fi
fi

## Finish
echo "Congratulations  You should now have ${USER} installed and configured."
echo "Please read the file Readme.md for more information."


