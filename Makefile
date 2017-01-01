VERSION := 1.12.5

ARCHIVE  := docker-$(VERSION).tgz
HASH     := docker-$(VERSION).hash
BINARIES := docker/bundles/$(VERSION)/binary-client/docker \
	docker/bundles/$(VERSION)/binary-daemon/docker-containerd \
	docker/bundles/$(VERSION)/binary-daemon/docker-containerd-ctr \
	docker/bundles/$(VERSION)/binary-daemon/docker-containerd-shim \
	docker/bundles/$(VERSION)/binary-daemon/docker-proxy \
	docker/bundles/$(VERSION)/binary-daemon/docker-runc \
	docker/bundles/$(VERSION)/binary-daemon/dockerd

all: $(ARCHIVE) $(HASH)

$(HASH): $(ARCHIVE)
	echo -n "sha256  " > $@
	sha256sum $(ARCHIVE) >> $@

$(ARCHIVE): $(BINARIES)
	sudo rm -rf docker/bundles/$(VERSION)/docker
	sudo mkdir -p docker/bundles/$(VERSION)/docker
	sudo cp $^ docker/bundles/$(VERSION)/docker/
	tar zcvf docker-$(VERSION).tgz -C docker/bundles/$(VERSION)/ docker

$(BINARIES): | docker
	cd docker && git fetch && git checkout v$(VERSION)
	$(MAKE) -C docker binary

docker:
	git clone https://github.com/docker/docker.git

clean:
	$(RM) $(ARCHIVE) $(HASH) $(BINARIES)

distclean: clean
	$(RM) -r docker

.PHONY: all clean distclean
