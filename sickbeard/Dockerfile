FROM debian:wheezy
MAINTAINER Nicholas Mead <najmead@gmail.com>

ENV GROUP media
ENV GROUPID 10000
ENV USER sickbeard
ENV SICKBEARDPORT 8081
ENV CONFIGDIR /etc/downloaders/sickbeard
ENV DATADIR /media

## Update apt-get and download latest updates
RUN apt-get -q update && apt-get -qy --force-yes dist-upgrade

## Install pre-requisites
RUN apt-get install -y git-core python-cheetah

## Download sickbeard source
RUN git clone git://github.com/midgetspy/Sick-Beard.git /opt/sickbeard

## Add a sickbeard user and media group
RUN groupadd -g ${GROUPID} ${GROUP} && useradd -u ${SICKBEARDPORT} -s /usr/sbin/nologin -g ${GROUP} ${USER}
RUN chown -R ${USER}:${GROUP} /opt/sickbeard
RUN mkdir -p ${CONFIGDIR} && chown -R ${USER}:${GROUP} ${CONFIGDIR}
RUN chmod u+rw ${CONFIGDIR}

## Expose the port sickbeard is expected to run on
VOLUME ${CONFIGDIR}
VOLUME ${DATADIR}
EXPOSE ${SICKBEARDPORT}

USER ${USER}

ENTRYPOINT ["/usr/bin/python", "/opt/sickbeard/SickBeard.py", "--datadir=/etc/downloaders/sickbeard"]
