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
RUN apt-get install python python-cherrypy git sudo -qy
RUN apt-get clean &&\
	rm -rf /var/lib/apt/lists/* &&\
	rm -rf /tmp/*

RUN git clone https://github.com/evilhero/mylar /opt/mylar

RUN groupadd -g ${GROUPID} ${GROUP} && useradd -u ${USERID} -s /usr/sbin/nologin -g ${GROUP} ${USER}
RUN chown -R ${USER}:${GROUP} /opt/mylar
RUN mkdir -p ${CONFIGDIR} && chown -R ${USER}:${GROUP} ${CONFIGDIR}
RUN chmod u+rw ${CONFIGDIR}

VOLUME ${CONFIGDIR}
VOLUME ${DATADIR}

EXPOSE ${SERVERPORT}

#USER ${USER}
RUN echo "#!/bin/bash" >> /opt/mylar/Start.sh
RUN echo "sudo -u ${USER} /usr/bin/python /opt/mylar/Mylar.py --datadir=${CONFIGDIR}" >> /opt/mylar/Start.sh
RUN chmod +x /opt/mylar/Start.sh

CMD ["/opt/mylar/Start.sh"]

