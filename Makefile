EXTERNAL_PATH ?= $(PWD)
GEM_CREDENTIALS ?= $(HOME)/.gem/credentials
VERSION ?= $(shell $(CAT) $(EXTERNAL_PATH)/lib/iso8601/version.rb \
                 | $(GREP) VERSION \
                 | $(AWK) '{print $$3}' \
                 | $(TR) -d \')

AWK ?= awk
CAT ?= cat
DOCKER ?= docker
DOCKER_TASK ?= $(DOCKER) run --rm -it
GIT ?= git
GREP ?= grep
TR ?= tr

image_name = arnau/iso8601
internal_path = /usr/src/iso8601
volumes = -v $(EXTERNAL_PATH):$(internal_path) \
          -v $(GEM_CREDENTIALS):/root/.gem/credentials

default: build

include mk/*.mk

test: mri-test rbx-test jruby-test
install: mri-pull rbx-pull jruby-pull
clean: mri-clean rbx-clean jruby-clean
build: mri-build rbx-build jruby-build
doc: mri-doc

repl: mri-repl
shell: mri-shell
check: mri-check
