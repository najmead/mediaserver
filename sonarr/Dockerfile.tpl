FROM debian:wheezy
MAINTAINER Nicholas Mead <najmead@gmail.com>

ENV GROUP xxxx
ENV GROUPID xxxx
ENV USER xxxx
ENV SERVERPORT xxxx
ENV CONFIGDIR xxxx
ENV DATADIR xxxx

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC
RUN echo "deb http://apt.sonarr.tv/ master main" | tee -a /etc/apt/sources.list
RUN apt-get update && apt-get dist-upgrade
RUN apt-get install nzbdrone

RUN apt-get clean &&\
	rm -rf /var/lib/apt/lists/* &&\
	rm -rf /tmp/*

RUN groupadd -g ${GROUPID} ${GROUP} && useradd -u ${SERVERPORT} -s /usr/sbin/nol
ogin -g ${GROUP} ${USER}
RUN chown -R ${USER}:${GROUP} /opt/sabnzbd
RUN mkdir -p ${CONFIGDIR} && chown -R ${USER}:${GROUP} ${CONFIGDIR}
RUN chmod u+rw ${CONFIGDIR}

## Create Volumes
VOLUME ${CONFIGDIR}
VOLUME ${DATADIR}

EXPOSE ${SERVERPORT}

USER ${USER}

ENTRYPOINT ["/usr/bin/mono", "/opt/NzbDrone/NzbDrone.exe", "-data=xxxx"]

