# READ ME

## The Basics

Please read the script Install.sh, customise the parameters according to your preferences and then run it.  Running Install.sh will take the Docker.tpl and create a customised dockerfile, and then build a docker image for sickbeard.  It will also take the Service.tpl and create a sickbeard.service to be used by systemd, install it, and set sickbeard to run automatically.

## WARNING

This script was built based on a Debian Jessie install.  It might work on other systems.  Or it might blow up.  It's probably a good idea to test it first in a non-critical environment.

## Pre-requisites

## Users and Groups

It is assumed that sickbeard will run on a dedicated user.  In order to manage permissions, a sickbeard user is created on the host system as well as in the docker container.  For consistency, the same userid will be used, which by default is 8081 (which is the same as the port number that sickbeard will be configured to run on).  This can be changed by configuring the parameters in the script Install.sh.

A group called media is also created.  Again, it is created on both the host system and the docker container, with a consistent groupid of 10000.  Make sure this groupid isn't already being used.  If it is, you can change the GROUPID parameter.

## Configuration folder

In order for configuration data to remain persistent, the Install.sh script will create a directory on the host system for configs, and share it with the docker image.  By default, the config directory is /etc/downloaders/sickbeard.

## Data

It is assumed that you have your TV shows stored in a single data directory on the host system.  By default, this is assumed to be /media, but it can be customised in the Install.sh script.  As with the configuration folder, it will be shared between the host and the docker container.

## Dockerfile

After running Install.sh, a Dockerfile will be created, and used to create a sickbeard image.  The resulting Dockerfile can be edited and reused if there are any errors.

## Systemd

The final step of the Install.sh script is to customise the Service.tpl to create a sickbeard.service for systemd.  This will then be copied to the systemd director (/etc/systemd/system), enabled and started.  This will ensure sickbeard starts on boot, and restarts if something wrong happens.  To disable, just run systemctl disable sickbeard.  Obviously, this will only work if you have systemd installed (see Prerequisites).

## Some commands to remember

If the image build fails, you may want to edit the Dockerfile and build it mannually.  Use the command;

docker build -t sickbeard .

To test the image and run it interactively, run;

docker run -i -t -v /etc/sickbeard:/etc/sickbeard -v /media:/media -p 8081:8081 --name sickbeard sickbeard

To try and diagnose issues with the image, you can override the ENTRYPOINT and attach to the running image with bash, using the following;

docker run -v /etc/sickbeard:/etc/sickbeard -v /media:/media --interactive --tty --entrypoint=/bin/bash sickbeard --login



