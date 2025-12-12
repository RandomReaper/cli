---
layout: post
title: '`ncdu` - a ncurses based `du`'
tags: ubuntu 24.04 server docker ngix
permalink: portainer-userns-nginx.html
image: /data/img/wide/tab.jpg
---

## Failed loading environment The environment named local is unreachable.

You're using `docker` with namespace isolation (**userns-remap**) and portainer can't access `/var/run/docker.sock`?

Here is the solution, please note the `--userns host`:

```bash
docker run --userns host -d --name portainer --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock:z -v portainer_data:/data portainer/portainer-ce:lts
```

No published ports, since [`ngix`](tag/ngix.html){:.set-5}, runs on the same host.


Here is the [`ngix`](tag/ngix.html){:.set-5} config:

```properties
server {
	server_name portainer.example.com;

	include snippets/my_ssl_config.conf;
	listen 443 ssl;
	listen [::]:443 ssl;

	location / {
		proxy_set_header Host $host;
		proxy_pass http://PORTAINER_IP:9000/;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto $scheme;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection "upgrade";
		proxy_http_version 1.1;
	}
}
```
