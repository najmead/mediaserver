[Unit]
Description=HTPC-Manager

[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=-/usr/bin/docker stop htpc
ExecStartPre=-/usr/bin/docker rm htpc
ExecStart=xxxx
ExecStop=/usr/bin/docker stop htpc

[Install]
WantedBy=multi-user.target

