#!/bin/bash

sudo apt update -y
sudo apt-get install -y net-tools zip curl jq tree unzip wget siege apt-transport-https ca-certificates software-properties-common gnupg lsb-release

# Download and install fake-service
sudo curl -LO https://github.com/nicholasjackson/fake-service/releases/download/v0.26.2/fake_service_linux_amd64.zip
sudo unzip fake_service_linux_amd64.zip
sudo rm -f fake_service_linux_amd64.zip
sudo mv fake-service /usr/bin/fake-service
sudo chmod 755 /usr/bin/fake-service
sudo chown ubuntu:ubuntu /usr/bin/fake-service

# Create systemd service
sudo tee /usr/lib/systemd/system/account.service > /dev/null << 'EOF'
[Unit]
Description=Account Service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Environment="LISTEN_ADDR=0.0.0.0:9092"
Environment="UPSTREAM_URIS=http://${statement_alb_dns}"
Environment="NAME=account-svc"
Environment="MESSAGE=HelloCloudBank | Retail Banking | account-svc"
ExecStart=/usr/bin/fake-service
User=ubuntu
Group=ubuntu
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sleep 1
sudo systemctl enable account.service
sudo systemctl start account.service
sleep 2
sudo systemctl status account.service