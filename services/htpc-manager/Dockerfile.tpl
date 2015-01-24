FROM debian:wheezy
MAINTAINER Nicholas Mead <najmead@gmail.com>

ENV GROUP xxxx
ENV GROUPID xxxx
ENV USER xxxx
ENV USERID xxxx
ENV SERVERPORT xxxx
ENV CONFIGDIR xxxx

## Take care of dependencies
RUN apt-get update && apt-get -qy --force-yes dist-upgrade
RUN apt-get install git python2.7 python-dev libjpeg8 libjpeg8-dev libpng12-dev libfreetype6 libfreetype6-dev zlib1g-dev python-pip sudo -qy
RUN pip install pillow
RUN git clone https://github.com/styxit/HTPC-Manager /opt/htpc

## Add a htpc user and media group
RUN groupadd -g ${GROUPID} ${GROUP} && useradd -u ${USERID} -s /usr/sbin/nologin -g ${GROUP} ${USER}
RUN chown -R ${USER}:${GROUP} /opt/htpc
RUN mkdir -p ${CONFIGDIR} && chown -R ${USER}:${GROUP} ${CONFIGDIR}
RUN chmod u+rw ${CONFIGDIR}

## Expose the port htpc-manager is expected to run on, and map the config directory
VOLUME ${CONFIGDIR}
EXPOSE ${SERVERPORT}


RUN echo "#!/bin/bash" >> /opt/htpc/Start.sh
RUN echo "sudo -u ${USER} /usr/bin/python /opt/htpc/Htpc.py --datadir=${CONFIGDIR}" >> /opt/htpc/Start.sh
RUN chmod +x /opt/htpc/Start.sh

CMD ["/opt/htpc/Start.sh"]
