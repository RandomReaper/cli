---
layout: post
title: 'jupyterhub'
tags: ubuntu 18.04 hw2018 server apache mysql python jupyter
permalink: jupyterhub.html
#image: /data/img/wide/www.jpg
---

Let's install jupyterhub, to run multiple notebooks, authenticated by apache
and **without existing local user**.

0. Prerequisites
  - A working [apache](/tag/apache.html) setup.
  - A working docker setup.
  - A working MySQL setup.

0. Create a user for the notebooks

    ```
    adduser nb
    Adding user `nb' ...
    Adding new group `nb' (1002) ...
    Adding new user `nb' (1002) with group `nb' ...
    Creating home directory `/home/nb' ...
    Copying files from `/etc/skel' ...
    Enter new UNIX password: 
    Retype new UNIX password: 
    passwd: password updated successfully
    Changing the user information for nb
    Enter the new value, or press ENTER for the default
    	Full Name []: Notebook
    	Room Number []: 
    	Work Phone []: 
    	Home Phone []: 
    	Other []: 
    Is the information correct? [Y/n] y
    
    adduser nb docker
    
    sudo loginctl enable-linger nb
    ```
0. Install packages

    ```
    sudo -i -H
    pip3 install jupyter
    pip3 install jupyterhub
    pip3 install notebook
    pip3 install jhub_remote_user_authenticator
    pip3 install dockerspawner
    npm install -g configurable-http-proxy
    exit
    docker pull jupyterhub/singleuser:0.9
    ```

0. `jupyterhub` configuration
    ```
    sudo -i -u nb
    jupyterhub --generate-config
    ```

  Edit `jupyterhub_config.py`:
  - `c.JupyterHub.ip = '127.0.0.1'`
  - `c.JupyterHub.authenticator_class = 'jhub_remote_user_authenticator.remote_user_auth.RemoteUserAuthenticator'`
  - `c.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'`
  - `c.RemoteUserAuthenticator.header_name = 'X-Forwarded-User'`



0. `jupyterhub` autostart

    ```
    sudo -i -u nb
    export XDG_RUNTIME_DIR="/run/user/$UID"
    export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
    ```

Create the directory `mkdir -p ~/.config/systemd/user` then the file `~/.config/systemd/user/jhub.service` file :

```config
[Unit]
Description=jupyterhub

[Service]
ExecStart=/usr/local/bin/jupyterhub -f jupyterhub_config.py

[Install]
WantedBy=default.target
```

Test it : `systemctl --user daemon-reload && systemctl --user enable jhub --now`, result in syslog:
