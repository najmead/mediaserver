FROM debian:wheezy
MAINTAINER Nicholas Mead <najmead@gmail.com>

ENV GROUP xxxx
ENV GROUPID xxxx
ENV USER xxxx
ENV USERID xxxx
ENV SERVERPORT xxxx
ENV CONFIGDIR xxxx
ENV DATADIR xxxx

RUN apt-get -q update && apt-get -qy --force-yes dist-upgrade

RUN apt-get -qy install git python psmisc sudo

RUN git clone https://github.com/RuudBurger/CouchPotatoServer.git /opt/couchpotato

RUN groupadd -g ${GROUPID} ${GROUP} && useradd -u ${USERID} -s /usr/sbin/nologin -g ${GROUP} ${USER}
RUN chown -R ${USER}:${GROUP} /opt/couchpotato
RUN mkdir -p ${CONFIGDIR} && chown -R ${USER}:${GROUP} ${CONFIGDIR}
RUN chmod u+rw ${CONFIGDIR}

VOLUME ${CONFIGDIR}
VOLUME ${DATADIR}
EXPOSE ${SERVERPORT}

#USER ${USER}

RUN echo "#!/bin/bash" >> /opt/couchpotato/Start.sh
RUN echo "sudo -u ${USER} /usr/bin/python /opt/couchpotato/CouchPotato.py --data_dir=${CONFIGDIR}" >> /opt/couchpotato/Start.sh
RUN chmod +x /opt/couchpotato/Start.sh

CMD ["/opt/couchpotato/Start.sh"]

#ENTRYPOINT ["sudo", "--user=xxxx", "/usr/bin/python", "/opt/couchpotato/CouchPotato.py", "--data_dir=xxxx"]

