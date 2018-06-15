---
layout: post
title: Use your outlook calendar from thunderbird+lightning
tags: ximport ubuntu thunderbird lightning outlook
permalink: /pages/thunderbird-lightning-outlook.html
---
## Required software parts
  - install thunderbird and lightning
  ```bash
  sudo apt-get install xul-ext-lightning
  ```
  - install the latest release of ExchangeCalendar
    - Download the .xpi from from [here](https://github.com/ExchangeCalendar/exchangecalendar/releases){:.external}
    - In thunderbird : tools > Add-ons > Plugins > settings > Install add-on from file ... (select the xpi)
    - restart thunderbird

## Setup the outlook calendar for yourself:

  - right-click, new calendar ..., on the network, microsoft exchange
  - choose a name for the calendar and your corresponding email -> next
  - server url for outlook 365 : https://outlook.office365.com/ews/exchange.asmx
  - server url for my job : https://outlook.hevs.ch/ews/exchange.asmx
  - primary address : your email address
  - username, for me the same as email address
    - -> check server (enter your password)
    - -> next

## Setup the outlook calendar for a colleague (will be read-only):

  - right-click, new calendar ..., on the network, microsoft exchange
  - choose a name for the calendar and email : none -> next
  - server url for outlook 365 : https://outlook.office365.com/ews/exchange.asmx
  - server url for my job : https://outlook.hevs.ch/ews/exchange.asmx
  - primary address : your colleague email address
  - username, your email address
    - -> check server (enter your password)
    - -> next