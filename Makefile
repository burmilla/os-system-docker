CLI_DIR:=$(CURDIR)/components/cli
ENGINE_DIR:=$(CURDIR)/components/engine
PACKAGING_DIR:=$(CURDIR)/components/packaging
VERSION=$(shell cat VERSION)
# target architecture in Go naming, defaults to the build host; any of ARCHS builds on any host
ARCH?=$(shell $(CURDIR)/detect_arch)
ARCHS:=amd64 arm64 loong64 riscv64

.PHONY: help
help: ## show make targets
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf " \033[36m%-20s\033[0m  %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: prepare
prepare: ## prepare the components
	GO111MODULE=off VERSION=$(VERSION) ./scripts/prepare

.PHONY: static
static:  ## build static packages
	$(MAKE) VERSION=$(VERSION) CLI_DIR=$(CLI_DIR) ENGINE_DIR=$(ENGINE_DIR) -C $(PACKAGING_DIR) ros-static-$(ARCH)
	mkdir -p $(CURDIR)/dist/
	cp -r components/packaging/static/build/* $(CURDIR)/dist/

.PHONY: static-all
static-all: ## build static packages for all of ARCHS
	for arch in $(ARCHS); do $(MAKE) ARCH=$$arch static || exit 1; done

.PHONY: release
release: static ## release
	GO111MODULE=off VERSION=$(VERSION) ./scripts/release

.PHONY: release-all
release-all: static-all ## release for all of ARCHS
	GO111MODULE=off VERSION=$(VERSION) ./scripts/release

.PHONY: clean
clean: ## clean the build artifacts
	-$(MAKE) -C $(CLI_DIR) clean
	-$(MAKE) -C $(ENGINE_DIR) clean
	-$(MAKE) -C $(PACKAGING_DIR) clean
	rm -rf dist
	rm -rf components
