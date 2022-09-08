# Install & Setup Cloudflared with Pi-Hole

### What is Cloudflared?
[Cloudflared](https://github.com/cloudflare/cloudflared) is a Tunnel client developed by Cloudflare that can encrypt DNS queries using [DNS-Over-HTTPS](https://www.rfc-editor.org/rfc/rfc8484) to supported DNS Servers

### Installing Cloudflared
**AMD64 architecture**:
```
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo apt-get install ./cloudflared-linux-amd64.deb
cloudflared -v
```

**armhf architecture** (32-bit ARM):
```
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm
sudo mv -f ./cloudflared-linux-arm /usr/local/bin/cloudflared
sudo chmod +x /usr/local/bin/cloudflared
cloudflared -v
```

**arm64 architecture** (64-bit ARM):
```
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64
sudo mv -f ./cloudflared-linux-arm64 /usr/local/bin/cloudflared
sudo chmod +x /usr/local/bin/cloudflared
cloudflared -v
```

### Configure cloudflared to run on startup
Create a `cloudflared` user to run the daemon:
```
sudo useradd -s /usr/sbin/nologin -r -M cloudflared
```

Create a configuration file for `cloudflared:`
```
sudo nano /etc/default/cloudflared
```

And add the folowing configuration:
```
# Default config can be replaced with other servers such as Google & Quad9
# Google: https://8.8.8.8/dns-query & https://8.8.4.4/dns-query
# Quad9: https://9.9.9.9/dns-query & https://149.112.112.112/dns-query

CLOUDFLARED_OPTS=--port 5053 --upstream https://1.1.1.1/dns-query --upstream https://1.0.0.1/dns-query
```

Update the permissions for the configuration file and cloudflared binary to allow access for the `cloudflared` user:
```
sudo chown cloudflared:cloudflared /etc/default/cloudflared
sudo chown cloudflared:cloudflared /usr/local/bin/cloudflared
```

Then create a `systemd` script by copying the following into `/etc/systemd/system/cloudflared.service` to allow it to run on startup:

```
sudo nano /etc/systemd/system/cloudflared.service
```
And add the folowing:
```
[Unit]
Description=cloudflared DNS over HTTPS proxy
After=syslog.target network-online.target

[Service]
Type=simple
User=cloudflared
EnvironmentFile=/etc/default/cloudflared
ExecStart=/usr/local/bin/cloudflared proxy-dns $CLOUDFLARED_OPTS
Restart=on-failure
RestartSec=10
KillMode=process

[Install]
WantedBy=multi-user.target

```

Enable the `systemd` service to run on startup & then start the service:
```
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

Test that queries get response by using the `dig` command:
```
dig @127.0.0.1 -p 5053 github.com
```

### Configure Pi-hole
Configure Pi-hole to use unbound as your recursive DNS server and untick any other upstream DNS Server:

**Settings -> DNS -> Custom 1 (IPv4)**

```
127.0.0.1#5053
```

Click save.

![screenshot at 2022-09-08](https://i.imgur.com/6Tnt3vb.png)

### Updating Cloudflared
Cloudflared is updated quite frequently and it is recommened that you update it at least once a month.

Run the script below that matches the architecture of your system:

**AMD64**: [AMD64-update.sh](https://raw.githubusercontent.com/adharc/pihole-cloudflared/main/AMD64-update.sh)
```
wget https://raw.githubusercontent.com/adharc/pihole-cloudflared/main/AMD64-update.sh
bash AMD64-update.sh
```

**armhf** (32-bit ARM): [armhf-update.sh](https://github.com/adharc/pihole-cloudflared/raw/main/armhf-update.sh)
```
wget https://github.com/adharc/pihole-cloudflared/raw/main/armhf-update.sh
bash armhf-update.sh
```

**arm64** (64-bit ARM): [arm64-update.sh](https://github.com/adharc/pihole-cloudflared/raw/main/arm64-update.sh)
```
wget https://github.com/adharc/pihole-cloudflared/raw/main/arm64-update.sh
bash arm64-update.sh
```
