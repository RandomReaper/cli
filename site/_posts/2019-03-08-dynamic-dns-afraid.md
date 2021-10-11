---
layout: post
title: 'Finding home - dynamic DNS (update #1)'
tags: ubuntu 18.04 hw2018 server network openwrt
permalink: dynamic-dns-afraid.html
description:
---

My [ISP](https://en.wikipedia.org/wiki/Internet_service_provider){:.external}
would like to charge me $10 a month for a fixed IPv4 address, but accessing your
machine remotely only needs a known address, not a fixed one, and that's why
[dynamic DNS](https://en.wikipedia.org/wiki/Dynamic_DNS){:.external}
have been invented.

There are plenty of providers for this service, but I use [FreeDNS](http://freedns.afraid.org/){:.external},
which provides this service for free for some hosts (5 as of today). Another reason to use this
service is that it does not need your account credentials for updates.

## Account setup
 - Go to the [FreeDNS pricing page](http://freedns.afraid.org/pricing/){:.external}, and select an account type,
 *starter* is free.
 - Fill in the blanks, confirm your email address, ...

## Host setup
 - Got the the [FreeDNS subdomain page](http://freedns.afraid.org/subdomain/){:.external}, login.
 - Click *Add a subdomain*
 - Fill the form
   - Type : A
   - subdomain : mysuperhostname
   - domain : mooo.com (or whichever you want)
   - destination : should be automatically filled with your current external IP address
   - Wildcard : not checked
   - Fill the captcha.
   - *Save!*
 - Now the [subdomain page](http://freedns.afraid.org/subdomain/){:.external} should show **mysuperhostname.mooo.com**.
 - Go the the [Dynamic DNS page](http://freedns.afraid.org/dynamic/){:.external}.

### Client setup : [ubuntu](/tag/ubuntu.html)
There are plenty of DDNS clients for ubuntu, but the **quick cron example** will just work
fine.
 - Click on **cron example**
 - Copy the file and add it to your cron (see [how](https://askubuntu.com/a/2369){:.external})
 - Replace `http://freedns.afraid.org/dynamic/` by `https://freedns.afraid.org/dynamic/`

    ```
    ...
    # You might need to include this path line in crontab, (or specify full paths)
    PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

    2,7,12,17,22,27,32,37,42,47,52,57 * * * * sleep 20 ; wget -O - http://freedns.afraid.org/dynamic/    update.php?V2VsY29tZSB0byBjbGkucGlnbmF0Lm9yZyAhCg== >> /tmp/freedns_mysuperhostname_mooo_com.log 2>&1 &
    ```

### Client install [openwrt](/tag/openwrt.html) 18.06.2+ (still working in 20.02.0)
I don't know since when, but at least in 18.06.2, ddns-scripts dont't use `wget`
anymore, so there is no more need to install it's full version.
- If you're using the web interface (`luci`):

    ```console
    opkg install luci-app-ddns ca-certificates
    ```
- Or without web interface support:

    ```console
    opkg install ddns-scripts ca-certificates
    ```

### Client install [openwrt](/tag/openwrt.html) older versions
- Since the default `wget` (from busybox) does not support https, the full
`wget` and the certificates must be installed:
  ```console
opkg update
opkg install wget ca-certificates
```
- If you're using the web interface (`luci`):
  ```console
opkg install luci-app-ddns
```
- Or without web interface support:
  ```console
opkg install ddns-scripts
```

### Client setup [openwrt](/tag/openwrt.html)
Edit the file `/etc/config/ddns`, choose a nice name for the config service, it
will be shown in the web interface:

```
config ddns 'global'
	option ddns_dateformat '%F %R'
	option ddns_loglines '250'
	option upd_privateip '0'

config service 'freedns_mysuperhostname_mooo_com'

    # Use the internet connected interface
	option interface 'wan'

	# Use afraid.org service
	option service_name 'afraid.org-keyauth'

	# Use this authentication key (could be found in the quick cron example)
	option password 'V2VsY29tZSB0byBjbGkucGlnbmF0Lm9yZyAhCg=='

	# Use https, since you don't want someone else to update your own IP
	option use_https '1'
	option cacert '/etc/ssl/certs/ca-certificates.crt'

	# Get the external IP from the dedicated google service
	option ip_source 'web'
	option ip_url 'https://domains.google.com/checkip'

	# Compare the external IP to this lookup, update when it differs
	option lookup_host 'mysuperhostname.mooo.com'

	# Enable!
	option enabled '1'
```

Restart the service:

```
/etc/init.d/ddns restart
```
## Verifications
The IP should be shown almost immediately on the [subdomain page](http://freedns.afraid.org/subdomain/){:.external}.
DNS propagation could be a little bit long (3600 seconds caching for free
accounts), and this can be verified using dig:
```shell
dig +short mysuperhostname.mooo.com
23.75.345.200
```
### DNS and caching
DNS answers can (and will) be cached by the DNS server, and a change in name
resolution will take some time to propagate. The duration of the validity for a
name resolution is included in the response, it's the TTL (time-to-live).

The time to live will be a fixed value when asking the authoritative name
server, for instance 60 seconds:

```console
dig +nocmd +noall +answer mysuperhostname.mooo.com @ns1.afraid.org
mysuperhostname.mooo.com. 60	IN	A	23.75.345.200
```

Or a value that decrement when asking another server:
```console
dig +nocmd +noall +answer mysuperhostname.mooo.com
mysuperhostname.mooo.com. 26	IN	A	23.75.345.200
```

Some providers does not follow the rules and may cache DNS entries longer.

## Notes
The update needs a shared secret, in this example `V2VsY29tZSB0byBjbGkucGlnbmF0Lm9yZyAhCg==`.
This one is completly fake, but the real one can be found on the
[Dynamic DNS page](http://freedns.afraid.org/dynamic/){:.external}, then by
looking in the *quick cron sample* or at the *direct url*.

## Bonus
```console
echo 'V2VsY29tZSB0byBjbGkucGlnbmF0Lm9yZyAhCg==' | base64 -d
```
