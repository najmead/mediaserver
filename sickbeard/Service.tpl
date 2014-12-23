[Unit]
Description=Sickbeard

[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=-/usr/bin/docker stop xxxx
ExecStartPre=-/usr/bin/docker rm xxxx
ExecStart=xxxx
ExecStop=/usr/bin/docker stop xxxx

[Install]
WantedBy=multi-user.target

