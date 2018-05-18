---
layout: post
title: adb shell settings put global guest_user_enabled 0
tags: ximport android
permalink: /pages/adb-shell-settings-guest.html
---
***EDIT: This one is an untested [import](/tags/ximports.html), but I like the mood***

ahahaha

```bash
adb shell settings put global guest_user_enabled 0
adb shell pm hide com.sonymobile.advancedwidget.entrance
adb shell pm hide com.sony.smallapp.launcher
adb shell pm hide com.sony.smallapp.app.widget
adb reboot
```