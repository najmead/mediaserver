FROM ubuntu:latest
MAINTAINER Nicholas Mead <najmead@gmail.com>

ENV GROUP xxxx
ENV GROUPID xxxx
ENV USER xxxx
ENV SERVERPORT xxxx
ENV CONFIGDIR xxxx
ENV DATADIR xxxx

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC
RUN echo "deb http://apt.sonarr.tv/ master main" | tee -a /etc/apt/sources.list
RUN apt-get -q update && apt-get -qy --force-yes dist-upgrade
RUN apt-get -qy install nzbdrone 

RUN apt-get clean &&\
	rm -rf /var/lib/apt/lists/* &&\
	rm -rf /tmp/*

RUN mkdir -p ${CONFIGDIR}
RUN groupadd -g ${GROUPID} ${GROUP} && useradd -u ${SERVERPORT} -s /usr/sbin/nologin -g ${GROUP} -d ${CONFIGDIR} ${USER}
RUN chown -R ${USER}:${GROUP} /opt/NzbDrone
RUN mkdir -p ${CONFIGDIR} && chown -R ${USER}:${GROUP} ${CONFIGDIR}
RUN chmod u+rw ${CONFIGDIR}

## Create Volumes
VOLUME ${CONFIGDIR}
VOLUME ${DATADIR}

EXPOSE ${SERVERPORT}

#USER ${USER}

ENTRYPOINT ["sudo", "--user=xxxx", "/usr/bin/mono", "/opt/NzbDrone/NzbDrone.exe", "-data=xxxx"]

