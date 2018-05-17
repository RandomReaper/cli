---
layout: post
title: Verifying certificates before deployment
tags: ximport ubuntu ssl openvpn
permalink: /pages/verify-ssl-certificate-before-deployment.html
---

Every time I setup an VPN using [openvpn](/tag/openvpn.html), I mess something in the certificates or keys.
Now I use [xca](http://xca.hohnstaedt.de/xca/){:.external} for managing my keys and my life is a little bit easier.

But once the certificates and keys are generated, I usually deploy them something don't work. The openvnp log contains something like :
```
VERIFY ERROR: depth=X, error=self signed certificate: ...
```

`openssl` offer a command for checking certificate chains before deployment:

```
openssl verify -CAfile ca.crt server.crt
```

If the response is not "client.crt: OK", there is no need trying to deploy your certificates.