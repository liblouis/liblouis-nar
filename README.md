Build
-----

    mvn clean install

To build for 32 bit on a 64 bit machine:

    mvn clean install -Dos.arch=i386

To cross-compile for Windows on Mac OS X (using [MinGW](http://crossgcc.rts-software.org/doku.php)):

    mvn clean install -Dhost.os=mingw32 -Dos.arch=i386

To install pkg-config on Mac OS X:

    brew install pkg-config
    sudo ln -s /usr/local/share/aclocal/pkg.m4 /usr/share/aclocal
