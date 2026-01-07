---
layout: post
title: ' `apache` - once again'
tags: ubuntu 24.04 server docker apache
permalink: apache-freeipa-ldap.html
---

```bash
apt-get install apache2 php8.3-fpm

a2enmod ssl headers auth_form authnz_ldap session_cookie session_crypto request session_crypto rewrite proxy_http proxy_wstunnel proxy_fcgi setenvif http2

a2enconf php8.3-fpm
```

```properties
<IfModule mod_ssl.c>
	<VirtualHost _default_:443>
		ServerName auth.example.com

		Protocols h2 http/1.1
    Include /etc/letsencrypt/options-ssl-apache.conf

		ProxyPreserveHost On
		RewriteEngine on
		RewriteRule ^/$ https://auth.example.com/ipa/ui [L,NC,R=301]

		<Location />
			ProxyPass http://172.20.0.3:80/ retry=0
			ProxyPassReverse http://172.20.0.3:80/
			Require all granted
		</Location>
</VirtualHost>
</IfModule>
```

```properties /var/lib/ipa-data/etc/httpd
# VERSION 7 - DO NOT REMOVE THIS LINE

RewriteEngine on

# By default forward all requests to /ipa. If you don't want IPA
# to be the default on your web server comment this line out.
#RewriteRule ^/$ https://auth.pignat.org/ipa/ui [L,NC,R=301]

# Redirect to the fully-qualified hostname. Not redirecting to secure
# port so configuration files can be retrieved without requiring SSL.
#RewriteCond %{HTTP_HOST}    !^auth.pignat.org$ [NC]
#RewriteCond %{HTTP_HOST}    !^ipa-ca.pignat.org$ [NC]
#RewriteRule ^/ipa/(.*)      http://auth.pignat.org/ipa/$1 [L,R=301]

# Redirect to the secure port if not displaying an error or retrieving
# configuration.
#RewriteCond %{SERVER_PORT}  !^443$
#RewriteCond %{REQUEST_URI}  !^/ipa/(errors|config|crl)
#RewriteCond %{REQUEST_URI}  !^/ipa/[^\?]+(\.js|\.css|\.png|\.gif|\.ico|\.woff|\.svg|\.ttf|\.eot)$
#RewriteRule ^/ipa/(.*)      https://auth.pignat.org/ipa/$1 [L,R=301,NC]

#RewriteCond %{HTTP_HOST}    ^ipa-ca.pignat.org$ [NC]
#RewriteCond %{REQUEST_URI}  !^/ipa/crl
#RewriteCond %{REQUEST_URI}  !^/(ca|kra|pki|acme)
#RewriteRule ^/(.*)          https://auth.pignat.org/$1 [L,R=301]

# Rewrite for plugin index, make it like it's a static file
RewriteRule ^/ipa/ui/js/freeipa/plugins.js$    /ipa/wsgi/plugins.py [PT]
```
