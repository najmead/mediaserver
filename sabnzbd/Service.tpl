[Unit]
Description=SABnzbd

[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=-/usr/bin/docker stop sabnzbd
ExecStartPre=-/usr/bin/docker rm sabnzbd
ExecStart=xxxx
ExecStop=/usr/bin/docker stop sabnzbd

[Install]
WantedBy=multi-user.target

