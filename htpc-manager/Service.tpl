[Unit]
Description=Sickbeard

[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=-/usr/bin/docker stop sickbeard
ExecStartPre=-/usr/bin/docker rm sickbeard
ExecStart=xxxx
ExecStop=/usr/bin/docker stop sickbeard

[Install]
WantedBy=multi-user.target

