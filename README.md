# Build

## Via CI

The recommended way to build is to let CI do the building for all
platforms. To trigger this, update the version number in `pom.xml`,
tag and push.

## Locally

To build for all platforms at once on your local machine:

``` console
$ docker-compose build debian
$ make clean all
```

**Note**: this only works if you have Docker and docker-compose
installed and make sure that `make` invokes `bash` (on Linux this is
not the case by default as `make` invokes plain `sh`)

This requires [Docker](https://www.docker.com). Mac binaries will only
be build if the host platform is Mac OS.

# Deploy

## Via CI

If you build via CI as described above the deployment is taken care
of.

## Locally

To deploy a snapshot to Sonatype OSS you need to

1. have credentials to deploy to sonatyle and
2. you need to put the username and the password in your local `settings.xml` file

To deploy a snapshot

``` console
$ make snapshot
```

To make a release:

``` console
$ make release
```
