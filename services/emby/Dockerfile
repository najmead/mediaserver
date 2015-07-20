# MediaBrowser Server
FROM debian:wheezy
MAINTAINER Nicholas Mead <najmead@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
#RUN locale-gen en_US en_US.UTF-8
#RUN update-locale LANG=en_US.UTF-8
#RUN dpkg-reconfigure locales

RUN apt-get update -qy
RUN apt-get install wget -qy

RUN wget -qO - http://download.opensuse.org/repositories/home:emby/Debian_7.0/Release.key | apt-key add -
RUN sh -c "echo 'deb http://download.opensuse.org/repositories/home:emby/Debian_7.0/ /' >> /etc/apt/sources.list.d/emby-server.list"
RUN apt-get update -qy
RUN apt-get install mono-runtime mediainfo libsqlite3-dev imagemagick-6.q8 libmagickwand-6.q8-2 libmagickcore-6.q8-2 -qy
RUN apt-get install emby-server -qy
RUN mkdir /config

EXPOSE 8096
EXPOSE 8920
EXPOSE 7359/udp
EXPOSE 1900/udp

RUN chown -R emby:emby /opt/emby-server
RUN chown -R emby:emby /config

VOLUME /config 
VOLUME /media

RUN echo "#!/bin/bash" >> /start.sh
RUN echo "cd /opt/emby-server" >> /start.sh
RUN echo "mono MediaBrowser.Server.Mono.exe -programdata /config" >> /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
