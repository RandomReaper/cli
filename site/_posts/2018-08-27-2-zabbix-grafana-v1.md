---
layout: post
title: 'System health monitoring (update #1)'
tags: ubuntu 18.04 hw2018 server apache zabbix grafana
permalink: server-18.04-zabbix-grafana.html
#image: /data/img/wide/www.jpg
---

**This post is an updated version of [that one](/server-18.04-zabbix-grafana-v0.html).**

Now that `apache` and `mysql` are [installed](/server-18.04-apache.html), here is my first use for them: [zabbix](/tag/zabbix.html).

# zabbix
Packages provides by ubuntu 18.04 are a little bit outdated, let's use the packages provided by upstream:

```console
wget http://repo.zabbix.com/zabbix/3.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.4-1+bionic_all.deb
sudo dpkg -i zabbix-release_3.4-1+bionic_all.deb
sudo apt-get update
sudo apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-agent zabbix-cli pwgen
sudo systemctl reload apache2
```

## Configure php

Edit `/etc/php/7.2/fpm/php.ini`, and change the following options (here is the [timezone list](https://secure.php.net/manual/en/timezones.php){:.external}):

```config
...
post_max_size = 16M
date.timezone = europe/zurich
max_execution_time = 300
max_input_time = 300
...
```
And restart php:
```
sudo systemctl restart php7.2-fpm.service
```

The rest of the zabbix setup is interactive, partly on your browser at https://YOUR_SERVER_IP_HERE/zabbix and partly in the console.

 - Welcome screen
   - ***Next step***
 - Check of pre-requisites
   - Should be OK because we already changed the php configuration.
   - ***Next step***
 - Open https://YOUR_SERVER_IP_HERE/phpmyadmin
   - Login as root
   - Goto the User accounts tab
   - Click add user
     - username : zabbix
     - host name : localhost
     - password : *click on generate and save it for later*
     - select : Create database with same name and grant all privileges.
      - Go
      - Select the SQL tab and execute::
      - ALTER DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;
 - On the console:
   ```
   zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -uzabbix -D zabbix -p
   ```
   - paste the password
   - wait some long time, 2 minutes here...
   - edit `/etc/zabbix/zabbix_server.conf`:
     ```
     DBPassword=paste the password
     ```
   - edit `/etc/zabbix/zabbix_agentd.conf`
     Hostname=YOUR_SERVER_NAME_HERE
 - Back into the browser, in the zabbix tab : Configure DB connection 
   - Paste the password
   - ***Next step***
 - Zabbix server details
   - Name : YOUR_SERVER_NAME_HERE
 - Pre-installation summary
   - ***Next step***
 - Congratulations
   - ***Finish***
 - Zabbix page
   -Login using Admin/zabbix
   - Change the password immediately here : Administration > Users > Admin > Change password
   - Enable monitoring of the server in Configuration > Hosts (click the "Disabled" red button)
 - On the console:
   ```
   sudo systemctl enable zabbix-server
   sudo systemctl restart zabbix-server
   sudo systemctl enable zabbix-agent
   sudo systemctl restart zabbix-agent
 ```

 # Create a zabbix user for grafana:
  - Administration > User groups > Create user group
    - name: grafana
    - permissions : select all, read then click add (in the permissions)
    - ***Add***
  - Administration > Users > Create user
    - alias: grafana
    - name: grafana
    - group: grafana
    - password: *use pwgen in the console*, save the result

## zabbix alerts by email
  - Create the file `/usr/lib/zabbix/alertscripts/mail`
 
  ```
#!/bin/bash

to=$1
subject=$2
body=$3

cat <<EOF | mail -s "$subject" root
TO:$to

$body

EOF
 ```
 - Make it executable.
 - Go to zabbix web interface, Administration > Media types
 - Disable all media type
 - Click create media type
   - Name : sendmail
   - Type : script
   - Script name : mail
   - parameters : 
     - {ALERT.SENDTO}
     - {ALERT.SUBJECT}
     - {ALERT.MESSAGE}
 - Go to Configuration > Report problems > enable
 - Go to Administration > User > Admin > Media
   - Add
   - type : sendmail
   - send to : unused
   - ***Add***

### Alert testing
Restart the zabbix server to enable emails, then watch the /var/log/mail.log
file, and try to stop the zabbix-agent service for 5 minutes. An email should be
sent.

Don't forget to restart the agent after testing.

## grafana
 - Package setup
```
curl https://packagecloud.io/gpg.key | sudo apt-key add -
sudo add-apt-repository "deb https://packagecloud.io/grafana/stable/debian/ stretch main"
sudo apt-get install grafana
```
 - grafana normally stores it's configuration into a sqlite file, but since
 mysql is already installed, let's use it:
     - Open https://YOUR_SERVER_IP_HERE/phpmyadmin
       - Login as root
       - Goto the User accounts tab
       - Click add user
         - username : grafana
         - host name : localhost
         - password : *click on generate and save it for later*
         - select : Create database with same name and grant all privileges.
          - Go
          - Select the SQL tab and execute::
          - ALTER DATABASE grafana CHARACTER SET utf8 COLLATE utf8_bin;
 - grafana will be hidden behind apache, so edit `/etc/grafana/grafana.ini`:
 ```
...
url = mysql://grafana:*paste the grafana mysql passord here*@localhost/grafana
...
http_addr=127.0.0.1
...
root_url = https://server-test-setup.mooo.com/grafana
...
 ```
 - prepare the apache redirection (in `/etc/apache2/sites-available/default-ssl.conf`)
   ```
   ...

                # BrowserMatch "MSIE [2-6]" \
                #               nokeepalive ssl-unclean-shutdown \
                #               downgrade-1.0 force-response-1.0


                ProxyPass         /grafana  http://localhost:3000
                ProxyPassReverse  /grafana  http://localhost:3000

                ProxyPreserveHost on

                <Proxy http://localhost:3000/*>
                        Order allow,deny
                        Allow from all
                </Proxy>


                <Directory "/var/www/html">
                AuthType Basic

   ...
   ```

 - install the grafna-zabbix plugin, reload apache and start grafana
 ```
sudo grafana-cli plugins install alexanderzobnin-zabbix-app
sudo systemctl enable grafana-server --now
sudo sudo a2enmod proxy_http
sudo systemctl reload apache2
 ```
 - log into https://YOUR_SERVER_IP_HERE/grafana, log in using admin/admin, and
 enter a suitable password.

## Linking zabbix to grafana

 - goto https://YOUR_SERVER_IP_HERE/grafana
 - login
 - Configuration > pluggins > zabbix > enable
 - Configuration > data sources > new
   - default data source : checked
   - name : zabbix
   - type : zabbix
   - url : https://localhost/zabbix/api_jsonrpc.php
   - skip TLS : checked (insecure but no problem on localhost)
   - username : grafana
   - password : *the password generated for grafana in zabbix*
   - ***Save and Test*** should display "Zabbix API version..."
