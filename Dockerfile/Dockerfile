FROM debian:wheezy
RUN apt-get update
RUN apt-get install -y make autoconf automake libtool pkg-config mingw32 mingw-w64
RUN apt-get install -y openjdk-7-jdk maven
RUN apt-get install -y git
RUN apt-get install -y curl
RUN apt-get install -y libc6-dev-i386
WORKDIR /tmp
RUN curl -L http://ftpmirror.gnu.org/texinfo/texinfo-5.2.tar.gz | tar zx
WORKDIR /tmp/texinfo-5.2
RUN ./configure
RUN make install
