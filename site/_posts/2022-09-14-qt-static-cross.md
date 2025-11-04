---
layout: post
title: Qt6 windows static executables compiled from linux
tags: qt ubuntu
permalink: /pages/qt-cross-static-1.html
---
Compiling Qt applications on windows for redistribution is utterly complicated, or impossible (missing dll, crashes, ...). So here is a way to compile *static* qt application, from your preferred unix-like.

Tested on ubuntu 20.04. LTS, see [mxe.cc](http://mxe.cc){:.external} for other unix-likes (even Mac OSX).

## Installation

- Install dependencies :
```bash
sudo apt-get install \
autoconf automake autopoint bash bison bzip2 cmake flex \
gettext git g++ gperf intltool libffi-dev libtool \
libltdl-dev libssl-dev libxml-parser-perl make openssl \
p7zip-full patch perl pkg-config python ruby scons sed \
unzip wget xz-utils git lzip libtool-bin python3-mako
```

- Clone mxe:
```bash
mkdir -p ~/git && cd ~/git
git clone https://github.com/mxe/mxe.git
cd mxe
```

- Configure (create the file) `settings.mk` for 32 and 64 bit
```
MXE_TARGETS := x86_64-w64-mingw32.static i686-w64-mingw32.static
```

- Compile it
```bash
make -j9 qt6
```



## Testing

```bash
# Qt project creation
mkdir /tmp/qt-test && cd /tmp/qt-test
echo 'QT += core gui opengl widgets
TEMPLATE = app
TARGET = hello
INCLUDEPATH += .
SOURCES += hello.cpp
' > test.pro
```

```bash
# main creation
echo '#include <QtWidgets/QApplication>
#include <QtWidgets/QLabel>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QLabel *label = new QLabel("Hello RandomReaper !");
    label->show();
    return app.exec();

}

' > hello.cpp
```

```bash
#compiling
mkdir build && cd build
export PATH=~/git/mxe/usr/bin/:$PATH
~/git/mxe/usr/x86_64-w64-mingw32.static/qt6/bin/qmake ..

make
...
```

```bash
# Result
file release/hello.exe
    release/hello.exe: PE32+ executable (GUI) x86-64 (stripped to external PDB), for MS Windows
```

## Compiling an existing Qt project
* Go to your project root (where the `.pro` is).
* ```bash
mkdir build && cd build
export PATH=~/git/mxe/usr/bin/:$PATH
~/git/mxe/usr/x86_64-w64-mingw32.static/qt6/bin/qmake ..
make
```
