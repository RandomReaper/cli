---
layout: post
title: "Ubuntu server and desktop with network bridge (for kvm)"
tags: ubuntu kvm
permalink: /pages/ubuntu-bridge-kvm.html
---

Ubuntu server uses `networkd` for network rendering and Ubuntu desktop uses
`NetworkManager`.

While you can find many places on the Internet explaining how to do a network
bridge using `NetworkManager`, I've never seen it work.

You can switch your entire desktop workstation to `networkd` but you will
lose the adantages of `NetworkManager` (WiFi, GUI support, ...).

But you may have missed that both `networkd` **and** `NetworkManager` can be
used together.

## Network bridge on the server (`/etc/netplan/01-config.yaml`)

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp3s0:
      dhcp4: false
  bridges:
    br0:
      macaddress: XX:XX:XX:XX:XX:XX
      dhcp4: false
      interfaces:
        - enp3s0
      addresses:
        - XXX.YYY.ZZZ.10/16
      routes:
        - to: default
          via: XXX.YYY.ZZZ.1
      nameservers:
        search:
          - "lan"
        addresses: [XXX.YYY.ZZZ.1]
```

## Network bridge on the desktop (`/etc/netplan/01-config.yaml`)

```yaml
network:
  version: 2
  ethernets:
    eno1:
      renderer: networkd
      dhcp4: false
  bridges:
    br0:
      renderer: networkd
      macaddress: YY:YY:YY:YY:YY:YY
      dhcp4: false
      addresses: [ "XXX.YYY.ZZZ.20/24" ]
      nameservers:
        addresses: [XXX.YYY.ZZZ.1]
        search: [lan]
      routes:
        - to: default
          via: XXX.YYY.ZZZ.1
      interfaces:
        - eno1
      parameters:
        forward-delay: 0
        stp: false
```

You may need to reboot to force `NetworkManager` to ignore `br0` and `eno1`.

## Install libvirt on all machines
```bash
sudo apt-get install libvirt-daemon-system libvirt-clients
sudo usermod -aG kvm,libvirt $USER
sudo -i -u $user # or logout+login to enable groups

# remove the default (NAT network)
virsh net-undefine default
virsh net-define /dev/stdin <<EOF
<network>
  <name>host-br0</name>
  <bridge name='br0'/>
  <forward mode="bridge"/>
</network>
EOF

virsh net-autostart host-br0
virsh net-start host-br0

# define a boot pool
sudo mkdir -p /var/lib/libvirt/boot
sudo wget -P /var/lib/libvirt/boot https://cdimage.ubuntu.com/ubuntu-mini-iso/noble/daily-live/current/noble-mini-iso-amd64.iso
sudo chown libvirt-qemu:kvm /var/lib/libvirt/boot -R

virsh pool-define /dev/stdin <<EOF
<pool type='dir'>
  <name>boot</name>
  <target>
    <path>/var/lib/libvirt/boot</path>
  </target>
</pool>
EOF

virsh pool-autostart boot
virsh pool-start boot
```

### On the desktop:
```bash
sudo apt-get install virt-manager
```

`virt-manager` will automatically connect to the local libvirt, but can be used to connect to a remote libvirt over ssh: `File -> Add Connection.. -> Connect
