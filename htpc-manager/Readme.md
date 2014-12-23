## Read Me

This script is designed to automatically install [HTPC Manager](http://htpc.io/) in a Docker container, including setup and basic configuration.

#### The Basics

Please read the script ``Install.sh``, customise the paramters according to your preferences and then run it.  Running the install script will take the ``Docker.tpl``, create a cutomised dockerfile, and then build a docker image.  It will also take the ``Service.tpl`` and create a service file to be used by systemd, install it and set it to run automatically.

#### WARNING

This script was built based on a Debian Jessie install.  It might work on other systems, or it might not.  Although Docker is designed to be portable, the install script runs a number of commands on the host system in order to make everything work nicely.  

#### Pre-requisites

This script assumes you already have Docker installed.  There may be a few other bits and pieces required.  Check out the project [readme](https://github.com/najmead/mediaserver/blob/master/Read.md) for more details.

#### Users and Groups

It is assumed that the service will run as a dedicated user.  In order to manage permissions, a dedicated user is created on both the host system as well as in the docker container.  For consistency, the same userid is used.  To help me keep track of things, the userid is the same as the default port number that the service is configured to run on.  This can be configured in the ``Install.sh``.  Make sure you use a userid that doesn't clash with an existing userid (you can check by looking at /etc/passwd).  

A group called media is also created.  Again, it is created on both the host system and the docker container, with a consistent groupid of 10000.  Make sure this groupid isn't already being used.  If the group has already been created (say, by running one of the other install scripts), this step is skipped.

#### Configuration Folder

In order for the configuration data to remain persistent, the ``Install.sh`` script will create a directory on the host system for configs, and share it with the docer image.  By default, the config directory is ``/etc/downloaders/htpc``.  HTPC Manager stores configs inside a sqlite database file called ``database.db`` inside the config directory.

#### Port Number

I like to use customied port numbers for applications, so the installation script will set the port based on the configurations in ``Install.sh``.  At the time of building, the script will then insert this port number into the settings database.  Once the HTPC Manager is up and running, you can override this by changing the port number (along with other settings) through the configuration screen.  However, the Docker image will still be listening on the original port.  So if you want to change port number, you'll need to change the container specifications as well.

#### Systemd

The final step of the script is to customise the ``Service.tpl`` to create a service for systemd.  This will then be copied to the systemd directory (ie, ``/etc/systemd/system/``), enabled and then stated.  This will ensure the service starts on boot, and restarts if something goes wrong.  

Be warned, once systemd is managing the container, trying to stop is with docker commands won't work.  Systemd will detect the container has stopped and immediately try and run it again.  Therefore, you'll need to issue the command ``systemctl stop htpc`` to stop the container.  Run ``systemctl disable htpc`` to disable it.

#### Some things to remember

If the image build fails, you may want to edit the Dockerfile and build it mannually.  Use the command;

``docker build -t htpc .``

To test the image and run it interactively, run;

``docker run -i -t -v /etc/downloaders/htpc:/etc/downloaders/htpc -p 7000:7000 --name htpc htpc``

To try and diagnose issues with the image, you can override the ENTRYPOINT and attach the running image with bash, using the following;

``docker run -v /etc/downloaders/htpc:/etc/downloaders/htpc -p 7000:7000 --interactive --tty --entrypoint=/bin/bash htpc --login``




 

