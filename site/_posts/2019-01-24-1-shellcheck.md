---
layout: post
title: '`shellcheck` - a shell script static analysis tool'
tags: ubuntu 18.04 16.04 shellcheck bash atom
permalink: shellcheck.html
---

Considering today's advent of CI and CD ([Continuous Integration and Continuous Development](https://en.wikipedia.org/wiki/Continuous_delivery){:.external}),
shell programming is still a thing and is still hard<sup>[\*1](/shellcheck.html#_nb1)</sup>,
but `shellcheck` is a tool that can save you<s>r life</s> a lot of time.

## Setup
```
sudo apt-get -y install shellcheck
```

## Usage
I won't write many more since there is a lot of documentation on the [`shellcheck`'s homepage](https://github.com/koalaman/shellcheck){:.external},
but I will emphasize that `shellcheck` can be run in many editors, including `vim`, `sublime text` and [`atom`](/tag/atom.html).











<br /><br /><br />
<a name="_nb1">*1</a> As of today, there are more than 120'000 questions tagged [bash](/tag/bash.html){:.set-1} on [unix.stackexchange](https://unix.stackexchange.com/questions/tagged/bash){:.exernal}
and [stackoverflow](https://stackoverflow.com/questions/tagged/bash){:.exernal}.
