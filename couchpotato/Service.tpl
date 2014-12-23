[Unit]
Description=Couchpotato

[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=-/usr/bin/docker stop couchpotato
ExecStartPre=-/usr/bin/docker rm couchpotato
ExecStart=xxxx
ExecStop=/usr/bin/docker stop couchpotato

[Install]
WantedBy=multi-user.target

