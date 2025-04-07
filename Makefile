MVN := mvn
DOCKER := docker
VERSION := $(shell xmllint --xpath "/*/*[local-name()='version']/text()" pom.xml)

TARGET_NAR_LINUX_32    := $(addprefix target/nar/louis-$(VERSION)-i386-Linux-gpp-,executable shared)
TARGET_NAR_LINUX_X64   := $(addprefix target/nar/louis-$(VERSION)-amd64-Linux-gpp-,executable shared)
TARGET_NAR_LINUX_ARM64 := $(addprefix target/nar/louis-$(VERSION)-aarch64-Linux-gpp-,executable shared)
TARGET_NAR_MAC_32      := $(addprefix target/nar/louis-$(VERSION)-i386-MacOSX-gpp-,executable shared)
TARGET_NAR_MAC_X64     := $(addprefix target/nar/louis-$(VERSION)-x86_64-MacOSX-gpp-,executable shared)
TARGET_NAR_MAC_ARM64   := $(addprefix target/nar/louis-$(VERSION)-aarch64-MacOSX-gpp-,executable shared)
TARGET_NAR_WIN_32      := $(addprefix target/nar/louis-$(VERSION)-i686-w64-mingw32-gpp-,executable shared)
TARGET_NAR_WIN_64      := $(addprefix target/nar/louis-$(VERSION)-x86_64-w64-mingw32-gpp-,executable shared)

.PHONY : all
all : compile-linux compile-windows
compile-linux : $(TARGET_NAR_LINUX_32) $(TARGET_NAR_LINUX_X64) $(TARGET_NAR_LINUX_ARM64)
compile-windows : $(TARGET_NAR_WIN_32) $(TARGET_NAR_WIN_64)

ifeq ($(shell uname -s),Darwin)
all : compile-macosx
ifeq ($(shell uname -m),x86_64)
compile-macosx : $(TARGET_NAR_MAC_X64)
else
compile-macosx : $(TARGET_NAR_MAC_ARM64)
endif
endif

.PHONY : clean
clean :
	$(MVN) clean

DOCKER_IMAGE_ := liblouis-nar_debian_

# can not use --platform linux/amd64,linux/arm64 (see https://github.com/docker/buildx/issues/59)
.PHONY : docker-images
docker-images :
	if ! $(DOCKER) images | grep $(DOCKER_IMAGE_)amd64 || ! $(DOCKER) images | grep $(DOCKER_IMAGE_)arm64; then \
		$(DOCKER) buildx create --use --name=mybuilder \
		                        --driver docker-container \
		                        --driver-opt image=moby/buildkit:buildx-stable-1 && \
		if ! $(DOCKER) images | grep $(DOCKER_IMAGE_)amd64; then \
			$(DOCKER) buildx build --platform linux/amd64 \
			                       -t $(DOCKER_IMAGE_)amd64 \
			                       --load \
			                       Dockerfile; \
		fi && \
		if ! $(DOCKER) images | grep $(DOCKER_IMAGE_)arm64; then \
			$(DOCKER) buildx build --platform linux/arm64 \
			                       -t $(DOCKER_IMAGE_)arm64 \
			                       --load \
			                       Dockerfile; \
		fi ; \
		$(DOCKER) buildx rm mybuilder; \
	fi

mvn-on-linux = $(MAKE) docker-images && \
	$(DOCKER) run --platform linux/$(call strip,$1) \
	              --rm \
	              -v "$(CURDIR):/root/src" \
	              -v "$(CURDIR)/.m2/repository:/root/.m2/repository" \
	              -w "/root/src" \
	              -it $(DOCKER_IMAGE_)$(call strip,$1) \
	              mvn $2

$(TARGET_NAR_LINUX_32) :
	$(call mvn-on-linux, amd64, test -Dos.arch=i386)

$(TARGET_NAR_LINUX_X64) :
	$(call mvn-on-linux, amd64, test)

$(TARGET_NAR_LINUX_ARM64) :
	$(call mvn-on-linux, arm64, test)

$(TARGET_NAR_MAC_32) :
	[[ "$$(uname -s)" == Darwin ]]
	$(MVN) test -Dos.arch=i386

$(TARGET_NAR_MAC_X64) :
	[[ "$$(uname -s)" == Darwin && "$$(uname -m)" == x86_64 ]]
	$(MVN) test

$(TARGET_NAR_MAC_ARM64) :
	[[ "$$(uname)" == Darwin && "$$(uname -m)" == arm64 ]]
	$(MVN) test

$(TARGET_NAR_WIN_32) :
	$(call mvn-on-linux, amd64, test -Pcross-compile -Dhost.os=w64-mingw32 -Dos.arch=i686)

$(TARGET_NAR_WIN_64) :
	$(call mvn-on-linux, amd64, test -Pcross-compile -Dhost.os=w64-mingw32 -Dos.arch=x86_64)

snapshot :
	[[ $(VERSION) == *-SNAPSHOT ]]
	$(MVN) nar:nar-prepare-package nar:nar-package install:install deploy:deploy

release :
	[[ $(VERSION) != *-SNAPSHOT ]]
	$(MVN) nar:nar-prepare-package nar:nar-package jar:jar gpg:sign install:install \
	       org.sonatype.plugins:nexus-staging-maven-plugin:1.6.8:deploy \
	       -Psonatype-deploy \
	       -DnexusUrl=https://oss.sonatype.org/ \
	       -DserverId=sonatype-nexus-staging \
	       -DstagingDescription='$(VERSION)' \
	       -DkeepStagingRepositoryOnCloseRuleFailure=true \
	       -DskipStagingRepositoryClose=true

install :
	$(MVN) nar:nar-prepare-package nar:nar-package jar:jar install:install
