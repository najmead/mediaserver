FROM debian:wheezy
MAINTAINER Nicholas Mead <najmead@gmail.com>

ENV GROUP xxxx
ENV GROUPID xxxx
ENV USER xxxx
ENV SERVERPORT xxxx
ENV CONFIGDIR xxxx
ENV DATADIR xxxx

RUN apt-get update && apt-get dist-upgrade -qy
RUN apt-get install python git -qy
RUN apt-get clean &&\
	rm -rf /var/lib/apt/lists/* &&\
	rm -rf /tmp/*

RUN git clone https://github.com/rembo10/headphones /opt/headphones

## Add a headphones user and media group
RUN groupadd -g ${GROUPID} ${GROUP} && useradd -u ${SERVERPORT} -s /usr/sbin/nologin -g ${GROUP} ${USER}
RUN chown -R ${USER}:${GROUP} /opt/headphones
RUN mkdir -p ${CONFIGDIR} && chown -R ${USER}:${GROUP} ${CONFIGDIR}
RUN chmod u+rw ${CONFIGDIR}

## Create Volumes
VOLUME ${CONFIGDIR}
VOLUME ${DATADIR}

## Expose the port sabnzbd will run on
EXPOSE ${SERVERPORT}

USER ${USER}

ENTRYPOINT ["/usr/bin/python", "/opt/headphones/Headphones.py", "--port=xxxx", "--datadir=xxxx"]
