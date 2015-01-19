FROM debian:jessie
MAINTAINER Nicholas Mead <najmead@gmail.com>

ENV GROUP xxxx
ENV GROUPID xxxx
ENV USER xxxx
ENV SERVERPORT xxxx
ENV CONFIGDIR xxxx
ENV DATADIR xxxx

## Prepare dependencies and then cleanup
RUN echo "deb http://http.debian.net/debian wheezy non-free" >> /etc/apt/sources.list.d/debian-nonfree.list
RUN apt-get update && apt-get upgrade -qy
RUN apt-get install python-cheetah par2 python-yenc unzip unrar git python-openssl sudo -qy
RUN apt-get clean &&\
	rm -rf /var/lib/apt/lists/* &&\
	rm -rf /tmp/*

## Clone sabnzbd
RUN git clone https://github.com/sabnzbd/sabnzbd /opt/sabnzbd

## Add a sabnzbd user and media group
RUN groupadd -g ${GROUPID} ${GROUP} && useradd -u ${SERVERPORT} -s /usr/sbin/nologin -g ${GROUP} ${USER}
RUN chown -R ${USER}:${GROUP} /opt/sabnzbd
RUN mkdir -p ${CONFIGDIR} && chown -R ${USER}:${GROUP} ${CONFIGDIR}
RUN chmod u+rw ${CONFIGDIR}

## Create Volumes
VOLUME ${CONFIGDIR}
VOLUME ${DATADIR}

## Expose the port sabnzbd will run on
EXPOSE ${SERVERPORT}

#USER ${USER}

ENTRYPOINT ["sudo", "--user=xxxx", "/usr/bin/python", "/opt/sabnzbd/SABnzbd.py", "--config-file=xxxx", "--server", ":xxxx"]
