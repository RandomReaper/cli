---
layout: post
title: "Disable ubuntu automatic upgrades (**all**)"
tags: ubuntu 24.04
permalink: /pages/ubuntu-disable-automaic-upgrades.html
---

Trust me, upgrades **MUST**[*1](#rfc2119) be **attended**.

{: #rfc2119}
\* *The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be
interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119){:.external}*.

## Disable automatic upgrades  
```bash
# disable unattended-upgrades
sudo systemctl disable unattended-upgrades
sudo systemctl stop unattended-upgrades

# disable firmware updates
sudo systemctl disable fwupd-refresh.timer
sudo systemctl stop fwupd-refresh.timer
sudo systemctl stop fwupd

# disable snap updates
sudo snap refresh --hold=forever

# disable update-notifier (so it won't trigger when we do a manual update)
sudo sed -i 's/DPkg::Post-Invoke/#DPkg::Post-Invoke/' /etc/apt/apt.conf.d/99update-notifier

# disable periodic apt updates
sudo sed -i 's/APT::Periodic::Update-Package-Lists "1"/APT::Periodic::Update-Package-Lists "0"/' /etc/apt/apt.conf.d/10periodic


# forget new packages in aptitude
echo 'Aptitude::Forget-New-On-Update "true";' | sudo tee /etc/apt/apt.conf.d/99aptitude-forget-new
```
