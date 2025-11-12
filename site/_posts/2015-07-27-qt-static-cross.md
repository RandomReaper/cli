---
layout: post
title: qt5 static executables compiled from linux
tags: ximport qt ubuntu xsuperseded
permalink: /pages/qt-cross-static-2.html
---
Compiling Qt applications on windows for redistribution is utterly complicated, or impossible (missing dll, crashes, ...). So here is a way to compile *static* qt application, from your preferred unix-like.

Tested on ubuntu 14.04.02 LTS and 15.04, see [mxe.cc](http://mxe.cc){:.external} for other unix-likes (even Mac OSX).

  - Install dependencies :
```bash
sudo apt-get install \
autoconf automake autopoint bash bison bzip2 cmake flex \
gettext git g++ gperf intltool libffi-dev libtool \
libltdl-dev libssl-dev libxml-parser-perl make openssl \
p7zip-full patch perl pkg-config python ruby scons sed \
unzip wget xz-utils git
```

  - Only on 15.04 (and later?)
```bash
sudo apt-get install libtool-bin
```

  - Clone mxe:
```bash
mkdir -p ~/git && cd ~/git
git clone https://github.com/mxe/mxe.git
cd mxe
```

  - Configure settings.mk for 32 and 64 bit
```
...
MXE_TARGETS := x86_64-w64-mingw32.static i686-w64-mingw32.static
...
```

  - Compile it
```bash
make -j9 qt5
```

  - Test it
```bash
# .pro creation
mkdir /tmp/qt-test && cd /tmp/qt-test
echo 'QT += core gui opengl
TEMPLATE = app
TARGET = hello
INCLUDEPATH += .
SOURCES += hello.cpp
' > test.pro
```

```bash
# hello.cpp creation
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

  - Compiling

```bash
mkdir ../qt-compile && cd ../qt-compile
~/git/mxe/usr/x86_64-w64-mingw32.static/qt5/bin/qmake ../qt-test
export PATH=~/git/mxe/usr/bin/:$PATH

make
...
```

  - Result
```bash
file release/hello.exe
    release/hello.exe: PE32+ executable (GUI) x86-64 (stripped to external PDB), for MS Windows
```
