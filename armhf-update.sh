#!/bin/bash
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm
sudo systemctl stop cloudflared
sudo mv -f ./cloudflared-linux-arm /usr/local/bin/cloudflared
sudo chmod +x /usr/local/bin/cloudflared
sudo systemctl start cloudflared
cloudflared -v
