#!/bin/bash

cd
rm -rf /root/udp
mkdir -p /root/udp

# change to time GMT+3
echo "change to time GMT+3"
ln -fs /usr/share/zoneinfo/America/Argentina /etc/localtime

# install udp-custom
echo downloading udp-custom
wget https://github.com/vpsvip7/1s/raw/main/udp-custom-linux-amd64 -O /root/udp/udp-custom &&
chmod +x /root/udp/udp-custom

echo downloading default config
wget https://raw.githubusercontent.com/vpsvip7/1s/main/config.json -O /root/udp/config.json &&
chmod 644 /root/udp/config.json

if [ -z "$1" ]; then
cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom by ePro Dev. Team

[Service]
User=root
Type=simple
ExecStart=/root/udp/udp-custom server
WorkingDirectory=/root/udp/
Restart=always
RestartSec=3s

[Install]
WantedBy=default.target
EOF
else
cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom by ePro Dev. Team

[Service]
User=root
Type=simple
ExecStart=/root/udp/udp-custom server -exclude $1
WorkingDirectory=/root/udp/
Restart=always
RestartSec=3s

[Install]
WantedBy=default.target
EOF
fi

echo start service udp-custom
systemctl start udp-custom &>/dev/null

echo enable service udp-custom
systemctl enable udp-custom &>/dev/null

echo history -c
echo reboot
reboot