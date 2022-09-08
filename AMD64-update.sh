#!/bin/bash
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo systemctl stop cloudflared
sudo apt-get install ./cloudflared-linux-amd64.deb
sudo systemctl start cloudflared
cloudflared -v
