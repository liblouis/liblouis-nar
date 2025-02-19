FROM debian:stretch
RUN echo "deb     http://archive.debian.org/debian stretch main"                    >/etc/apt/sources.list
RUN echo "deb-src http://archive.debian.org/debian stretch main"                   >>/etc/apt/sources.list
RUN echo "deb     http://archive.debian.org/debian stretch-backports main"         >>/etc/apt/sources.list
RUN echo "deb     http://archive.debian.org/debian-security stretch/updates main"  >>/etc/apt/sources.list
RUN echo "deb-src http://archive.debian.org/debian-security stretch/updates main"  >>/etc/apt/sources.list
ARG TARGETARCH
RUN apt-get update && \
    apt-get install -y make \
                       autoconf \
                       automake \
                       libtool \
                       pkg-config \
                       texinfo \
                       openjdk-8-jdk \
                       maven \
                       git && \
    if [ "${TARGETARCH}" = amd64 ]; then \
        apt-get install -y libc6-dev-i386 \
                           mingw-w64; \
    fi
