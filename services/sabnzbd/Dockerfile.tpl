FROM debian:wheezy
MAINTAINER Nicholas Mead <najmead@gmail.com>

ENV GROUP xxxx
ENV GROUPID xxxx
ENV USER xxxx
ENV USERID xxxx
ENV SERVERPORT xxxx
ENV CONFIGDIR xxxx
ENV DATADIR xxxx

## Prepare dependencies and then install
RUN echo "deb http://http.debian.net/debian wheezy non-free" >> /etc/apt/sources.list.d/debian-nonfree.list
RUN echo "deb http://ppa.launchpad.net/jcfp/ppa/ubuntu precise main" | tee -a /etc/apt/sources.list
RUN apt-key adv --keyserver hkp://pool.sks-keyservers.net:11371 --recv-keys 0x98703123E0F52B2BE16D586EF13930B14BB9F05F
RUN apt-get update && apt-get upgrade -qy

## Install
RUN apt-get -o APT::Install-Recommends=1 install sabnzbdplus sabnzbdplus-theme-mobile unrar sudo -qy

RUN apt-get clean &&\
        rm -rf /var/lib/apt/lists/* &&\
        rm -rf /tmp/*
 
## Add a sabnzbd user and media group
RUN groupadd -g ${GROUPID} ${GROUP} && useradd -u ${USERID} -s /usr/sbin/nologin -g ${GROUP} ${USER}
RUN mkdir -p ${CONFIGDIR} && chown -R ${USER}:${GROUP} ${CONFIGDIR}
RUN chmod u+rw ${CONFIGDIR}

## Create Volumes
VOLUME ${CONFIGDIR}
VOLUME ${DATADIR}

## Expose the port sabnzbd will run on
EXPOSE ${SERVERPORT}

## Create a start script that we can customise whenever required
RUN echo "#!/bin/bash" >> /Start.sh
RUN echo "sudo -u ${USER} /usr/bin/sabnzbdplus --config-file=${CONFIGDIR}" >> /Start.sh
RUN chmod +x /Start.sh

## Create Volumes
VOLUME ${CONFIGDIR}
VOLUME ${DATADIR}

ENTRYPOINT ["/Start.sh"]

