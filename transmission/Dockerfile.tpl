FROM debian:wheezy
MAINTAINER Nicholas Mead <najmead@gmail.com>

ENV GROUP xxxx
ENV GROUPID xxxx
ENV USER xxxx
ENV SERVERPORT xxxx
ENV CONFIGDIR xxxx
ENV DATADIR xxxx

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get dist-upgrade -qy
RUN DEBIAN_FRONTEND=noninteractive apt-get install transmission-daemon -qy
RUN DEBIAN_FRONTEND=noninteractive apt-get clean &&\
	rm -rf /var/lib/apt/lists/* &&\
	rm -rf /tmp/*

RUN DEBIAN_FRONTEND=noninteractive groupadd -g ${GROUPID} ${GROUP} && useradd -u ${SERVERPORT} -s /usr/sbin/nologin -g ${GROUP} ${USER}
RUN DEBIAN_FRONTEND=noninteractive mkdir -p ${CONFIGDIR} && chown -R ${USER}:${GROUP} ${CONFIGDIR}
RUN DEBIAN_FRONTEND=noninteractive chmod u+rw ${CONFIGDIR}

## Create Volumes
VOLUME ${CONFIGDIR}
VOLUME ${DATADIR}

## Expose the port sabnzbd will run on
EXPOSE ${SERVERPORT}

USER ${USER}

ENTRYPOINT ["transmission-daemon", "--config-dir=xxxx", "--foreground"]
