Mediaserver
===========

##What is this?

Here are a series of scripts I'm working on to automate the build of my home server.  They are designed to run on a debian jessie installation, but will probably work on other versions of Debian.  With a bit of time, I'll try and customise and test them on some other Linux platforms.

The following services are in progress, or mostly completed;

#### Content Finders
- Sickbeard (Port 9000) [Complete]
- Sonarr / NzbDrone (Port 9001) [Complete]
- Couchpotato (Port 9002) [Complete]
- Headphones (Port 9003) [Complete]
- Mylar (Port 9004) [Complete]

#### Downloaders
- SABnzbd+ (Port 8000) [Complete]
- NZBGet (Port 8001) [To be done]
- Transmission (Port 8002) [To be done]
- Deluge (Port 8003) [Complete -- sort of]

#### Managers
- HTPC Manager (Port 7000) [Complete]
- Maraschino (Port 7001) [To be done]

#### Content Servers
- Subsonic (Port ????) [To be done]

##Docker

Each of the applications here is built using docker.  For more information, check out the Docker [homepage](https://www.docker.com/).

##Prerequisites

There's some stuff that probably needs to be installed before these scripts will work.  I'll add that information as it comes to me. 

Here's the steps I followed...

Download and install the Debian Jessie netinstall.  Run the installation, and de-select most of the options (no need for a desktop environment), with the exception of ssh (this will be useful).  Once the install is complete, ssh into the new server.  Install the packages git and docker.io (you may need to reboot after installing docker).  Clone the this repository.  Then pick the various packages you want, and run the Install.sh script for each of them.



