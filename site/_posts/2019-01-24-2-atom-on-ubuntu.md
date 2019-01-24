---
layout: post
title: '`atom` - yet another editor'
tags: ubuntu 18.04 16.04 shellcheck atom
permalink: atom-on-ubuntu.html
---

## Setup (kindly borrowed from [atom's flight manual](https://flight-manual.atom.io/getting-started/sections/installing-atom/){:.external})
```
wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
sudo apt-get update
sudo apt-get -y install atom
```

## Plugins
Plugins can be installed using "Edit/Preferences/Install", Here are a quick
selection:

| Plugin | Description | Remark |
|-|-|
| linter-shellcheck         | [`shellcheck`](/tag/shellcheck.html) integration | Don't forget to enable "Enable Notice Message" |
| language-vhdl | VHDL syntax and snippets | - |
| linter-vhdl | A VHDL linter | May require ghdl |
