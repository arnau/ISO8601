TAG ?= latest
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

image_name = arnau/iso8601:$(TAG)
internal_path = /usr/src/iso8601
volumes = -v $(EXTERNAL_PATH):$(internal_path) \
          -v $(GEM_CREDENTIALS):/root/.gem/credentials

install: build
##
# Release gem to Rubygems. VERSION required.
release: gem-build gem-push git-tag
##
# Run unit tests
test:
	@$(call task)
##
# Open Ruby repl
shell:
	@$(call task, pry -r $(internal_path)/lib/iso8601)
##
# Build docker image
build:
	@$(DOCKER) build -t $(image_name) .
##
# Build gem file
gem-build:
	@$(call task, rake build)
##
# Push gem file to Rubygems
gem-push:
	@$(call task, gem push $(internal_path)/pkg/iso8601-$(VERSION).gem)
##
# Tag version to git
git-tag:
	@$(GIT) tag v$(VERSION)

version:
	@echo "$(VERSION)"


define task
	$(DOCKER_TASK) $(volumes) $(image_name) $1
endef
