apt-get install squid3 

mkdir /var/cache/squid
chown proxy:proxy /var/cache/squid
cp /etc/squid3/squid.conf /etc/squid3/squid.conf.dist

#Setup cache
/usr/sbin/squid3 -N -z -F

