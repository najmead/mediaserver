FROM debian:wheezy
MAINTAINER Nicholas Mead <najmead@gmail.com>

ENV GROUP xxxx
ENV GROUPID xxxx
ENV USER xxxx
ENV USERID xxxx
ENV SERVERPORT xxxx
ENV CONFIGDIR xxxx
ENV DATADIR xxxx

RUN apt-get update && apt-get dist-upgrade -qy
RUN apt-get install python git sudo -qy
RUN apt-get clean &&\
	rm -rf /var/lib/apt/lists/* &&\
	rm -rf /tmp/*

RUN git clone https://github.com/rembo10/headphones /opt/headphones

## Add a headphones user and media group
RUN groupadd -g ${GROUPID} ${GROUP} && useradd -u ${USERID} -s /usr/sbin/nologin -g ${GROUP} ${USER}
RUN chown -R ${USER}:${GROUP} /opt/headphones
RUN mkdir -p ${CONFIGDIR} && chown -R ${USER}:${GROUP} ${CONFIGDIR}
RUN chmod u+rw ${CONFIGDIR}

## Create Volumes
VOLUME ${CONFIGDIR}
VOLUME ${DATADIR}

## Expose the port sabnzbd will run on
EXPOSE ${SERVERPORT}

#USER ${USER}
RUN echo "#!/bin/bash" >> /opt/headphones/Start.sh
RUN echo "sudo -u ${USER} /usr/bin/python /opt/headphones/Headphones.py --datadir=${CONFIGDIR} --config=${CONFIGDIR}/config.ini" >> /opt/headphones/Start.sh
RUN chmod +x /opt/headphones/Start.sh

CMD ["/opt/headphones/Start.sh"]

