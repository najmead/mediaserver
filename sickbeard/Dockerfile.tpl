FROM debian:jessie
MAINTAINER Nicholas Mead <najmead@gmail.com>

ENV GROUP xxxx
ENV GROUPID xxxx
ENV USER xxxx
ENV SICKBEARDPORT xxxx
ENV CONFIGDIR xxxx
ENV DATADIR xxxx

## Update apt-get and download latest updates
RUN apt-get -q update && apt-get -qy --force-yes dist-upgrade

## Install pre-requisites
RUN apt-get install -y git-core python-cheetah sudo

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

#USER ${USER}

ENTRYPOINT ["sudo", "--user=xxxx", "/usr/bin/python", "/opt/sickbeard/SickBeard.py", "--datadir=xxxx"]
