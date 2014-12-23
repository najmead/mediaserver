FROM debian:wheezy
MAINTAINER Nicholas Mead <najmead@gmail.com>

ENV GROUP xxxx
ENV GROUPID xxxx
ENV USER xxxx
ENV SERVERPORT xxxx
ENV CONFIGDIR xxxx
ENV DATADIR xxxx

RUN apt-get update && apt-get dist-upgrade
RUN apt-get install python python-cherrypy git -y
RUN apt-get clean &&\
	rm -rf /var/lib/apt/lists/* &&\
	rm -rf /tmp/*

RUN git clone https://github.com/evilhero/mylar /opt/mylar

RUN groupadd -g ${GROUPID} ${GROUP} && useradd -u ${SERVERPORT} -s /usr/sbin/nologin -g ${GROUP} ${USER}
RUN chown -R ${USER}:${GROUP} /opt/mylar
RUN mkdir -p ${CONFIGDIR} && chown -R ${USER}:${GROUP} ${CONFIGDIR}
RUN chmod u+rw ${CONFIGDIR}

VOLUME ${CONFIGDIR}
VOLUME ${DATADIR}

EXPOSE ${SERVERPORT}

USER ${USER}

ENTRYPOINT ["/usr/bin/python", "/opt/mylar/Mylar.py", "--port=xxxx", "--datadir=xxxx"]
