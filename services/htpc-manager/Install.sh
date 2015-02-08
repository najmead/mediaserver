#!/bin/bash

############# Set some parameters #############
GROUP="media"
USER="htpc"
SERVERPORT="8000"
URLBASE="htpc"
CONFIGDIR="/etc/downloaders/${USER}"
##DATADIR="/export"
###############################################

## Check to see if group exists, if not, create it.
getent group "${GROUP}" > /dev/null
if [ $? -eq 0 ]; then
	GROUPID="$(getent group ${GROUP} | cut -d: -f3)"
	echo "Group $GROUP with gid ${GROUPID} already exists, no need to create."
else
	echo "Group $GROUP does not exist, so creating it..."
	groupadd -r ${GROUP}
	GROUPID="$(getent group ${GROUP} | cut -d: -f3)"
fi

## Check to see if user exists, if not, create it.
echo   "Setting up user $USER"
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
	sed -i s#ENV\ SERVERPORT\ xxxx#ENV\ SERVERPORT\ ${SERVERPORT}# Dockerfile
	sed -i s#ENV\ CONFIGDIR\ xxxx#ENV\ CONFIGDIR\ ${CONFIGDIR}# Dockerfile
	sed -i s#ENV\ DATADIR\ xxxx#ENV\ DATADIR\ ${DATADIR}# Dockerfile
	sed -i s#ENV\ GROUP\ xxxx#ENV\ GROUP\ ${GROUP}# Dockerfile
	sed -i s#ENV\ GROUPID\ xxxx#ENV\ GROUPID\ ${GROUPID}# Dockerfile

	echo "Setting ENTRYPOINT"
	sed -i s#--user=xxxx#--user=${USER}# Dockerfile
	sed -i s#--datadir=xxxx#--datadir=${CONFIGDIR}# Dockerfile

	echo "Building image"
	docker build -t "${USER}" .
fi

if [ -e ${CONFIGDIR}/database.db ]; then
	echo "Config database already exists, so I won't touch it.  Double check that the port list in the config matches the specified port, ${SERVERPORT}."
else
	TEMP_CONT=$RANDOM
	echo "Running ${USER} in a temporary container ( ${TEMP_CONT} ) for the first time to generate a config."
	docker run -d -v ${CONFIGDIR}:${CONFIGDIR} --name=${TEMP_CONT} ${USER}
	echo "Snooze for a moment, to give ${USER} time to setup."
	sleep 10
	echo "Ok, now let's stop the temporary container ( ${TEMP_CONT} )"
	docker stop ${TEMP_CONT}
	echo "Insert the specified port ${SERVERPORT} and the URL path /${URLBASE} into the config database."
	echo "I'll need sqlite3..."
	s=$(which sqlite3 > /dev/null;echo $?)
	if [ $s -eq 0 ]; then
		echo "...you already have it installed"
	else
		echo "...I'll install it temporarily."
		apt-get update && apt-get install sqlite3 -qy
	fi
	sqlite3 ${CONFIGDIR}/database.db "insert into setting (key, val) values ('app_port', ${SERVERPORT});"
	sqlite3 ${CONFIGDIR}/database.db "insert into setting (key, val) values ('app_webdir', '/${URLBASE}');"
	if [ $s -eq 0 ]; then
		echo "No cleanup required." 
	else
		echo "Cleaning up."
		apt-get remove -qy sqlite3
	fi
	echo "Snooze a little bit more so I can check some things."
	sleep 10
	docker rm ${TEMP_CONT}
fi

if [ $(ps -p 1 -o comm=) == "systemd" ];
then
	echo "Looks like you are running systemd, I'll try and create a service."

	## Add systemd file
	if [ -e /etc/systemd/system/${USER}.service ]; then
		echo "${USER} service already exists."
	else
		echo "Adding ${USER} service to systemd."
		echo "Customising ${USER}.service"
		cp Service.tpl ${USER}.service
		sed -i s#Description=xxxx#Description=${USER}# ${USER}.service
		sed -i s#ExecStart=xxxx#ExecStart=/usr/bin/docker\ run\ -v\ ${CONFIGDIR}:${CONFIGDIR}\ -v\ \/etc\/localtime:\/etc\/localtime:ro\ -p\ ${SERVERPORT}:${SERVERPORT}\ --name=${USER}\ ${USER}# ${USER}.service
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
		docker run -v ${CONFIGDIR}:${CONFIGDIR} -v /etc/localtime:/etc/localtime:ro -p ${SERVERPORT}:${SERVERPORT} --name=${USER} -d --restart=always ${USER}
	fi
fi

## Finish
echo "Congratulations.  You should now have ${USER} installed and configured."
echo "Please read the file Readme.md for more information."


