FROM debian:wheezy
MAINTAINER Nicholas Mead <najmead@gmail.com>

ENV GROUP xxxx
ENV GROUPID xxxx
ENV USER xxxx
ENV SERVERPORT xxxx
ENV CONFIGDIR xxxx
ENV DATADIR xxxx

RUN apt-get -q update && apt-get -qy --force-yes dist-upgrade

RUN apt-get -qy install deluged deluge-web

RUN apt-get clean &&\
	rm -rf /var/lib/apt/lists/* &&\
	rm -rf /tmp/*

RUN groupadd -g ${GROUPID} ${GROUP} && useradd -u ${SERVERPORT} -s /usr/sbin/nologin -g ${GROUP} ${USER}
RUN mkdir -p ${CONFIGDIR} && chown -R ${USER}:${GROUP} ${CONFIGDIR}
RUN chmod u+rw ${CONFIGDIR}

RUN echo "#!/bin/bash" >> start.sh &&\
	echo "deluged --config=${CONFIGDIR}" >> start.sh &&\ 
	echo "deluge-web --config=${CONFIGDIR} --port=${SERVERPORT}" >> start.sh

RUN chmod +x start.sh

EXPOSE 53160
EXPOSE 53160/udp
EXPOSE ${SERVERPORT}
EXPOSE 58846

VOLUME ${CONFIGDIR}
VOLUME ${DATADIR}

USER ${USER}

ENTRYPOINT ["/start.sh"]

