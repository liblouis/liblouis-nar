FROM debian:stretch

FROM debian:jessie

LABEL maintainer="Liblouis Maintainers <liblouis-liblouisxml@freelists.org>"

# Fetch build dependencies
RUN apt-get update && apt-get install -y \
    make \
    autoconf \
    automake \
    libtool \
    pkg-config \
    texinfo \
    libc6-dev-i386 \
    mingw-w64 \
    openjdk-8-jdk \
    maven \
    git \
   && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
