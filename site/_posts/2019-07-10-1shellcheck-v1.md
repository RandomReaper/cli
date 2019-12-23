---
layout: post
title: '`shellcheck` - a shell script static analysis tool (update #1)'
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
but I will emphasize that `shellcheck` can be run in many editors, including `vim`, `sublime text` and [`atom`](/tag/atom.html),
([here is the setup for atom on ubuntu](/atom-on-ubuntu.html)).

## Tip
Search the SCXXXX code in your favorite search engine, it will direct you to the `shellcheck`'s wiki with the full explanation and some advice for fixing the code. example:

`test.sh` sample file:
```source
#!/bin/bash
echo $0
```
`shellcheck` output:

```console
shellcheck test.sh

In test.sh line 2:
echo $0
     ^-- SC2086: Double quote to prevent globbing and word splitting.
```








<br /><br /><br />
<a name="_nb1">*1</a> As of today, there are more than 18'000 questions tagged [bash](/tag/bash.html){:.set-1} on [unix.stackexchange](https://unix.stackexchange.com/questions/tagged/bash){:.exernal}
and [stackoverflow](https://stackoverflow.com/questions/tagged/bash){:.exernal}.
