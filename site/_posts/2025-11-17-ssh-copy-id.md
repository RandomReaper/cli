---
layout: post
title: ssh key deployment
tags: ssh
permalink: /pages/ssh-copy-id.html
image: /data/img/wide/tab.jpg
---

You may edit `~/.ssh/authorized_keys'` manually on a remote host, or use `cat ~/.ssh/id_rsa.pub | ssh user@host 'cat >> ~/.ssh/authorized_keys'`, but there is a command for that: `ssh-copy-id` (full man page [here](https://man7.org/linux/man-pages/man1/ssh-copy-id.1.html){:.external}).

## Examples
  * Add your `ssh` public key to `remoteuser@remotehost.example.com`
      ```bash
      someone@somemachine:~$  ssh-copy-id remoteuser@remotehost.example.com
      /usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to  filter out any that are already installed
      /usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are  prompted now it is to install the new keys
      remoteuser@remotehost.example.com password: *********

      Number of key(s) added: 1

      Now try logging into the machine, with:   "ssh remoteuser@remotehost.example.com"
      and check to make sure that only the key(s) you wanted were added.

      someone@somemachine:~$
      ```
      :point_up: You may have noticed that I put a space before "ssh-copy-id", here is why : [HISTCONTROL variable in bash](https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html){:.external}.
  * Add your ssh key with a custom comment:
      ```bash
      someone@somemachine:~$  ssh-copy-id -i my_key_with_a_custom_comment.pub remoteuser@remotehost.example.com
      /usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "my_key_with_a_custom_comment.pub"
      /usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to  filter out any that are already installed
      /usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are  prompted now it is to install the new keys
      remoteuser@remotehost.example.com password: *********

      Number of key(s) added: 1

      Now try logging into the machine, with:   "ssh remoteuser@remotehost.example.com"
      and check to make sure that only the key(s) you wanted were added.

      someone@somemachine:~$
      ```
  * Add your ssh key with a custom comment using another key for authentification :warning: this one doesn't work without the `-f` flag, which will add the public key even if already present:
      ```bash
      someone@somemachine:~$  ssh-copy-id -f -i my_key_with_a_custom_comment.pub -o "IdentityFile ~/.ssh/id_rsa.old" remoteuser@remotehost.example.com
      /usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "my_key_with_a_custom_comment.pub"
      /usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to  filter out any that are already installed
      /usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are  prompted now it is to install the new keys
      remoteuser@remotehost.example.com password: *********

      Number of key(s) added: 1

      Now try logging into the machine, with:   "ssh remoteuser@remotehost.example.com"
      and check to make sure that only the key(s) you wanted were added.

      someone@somemachine:~$
      ```
