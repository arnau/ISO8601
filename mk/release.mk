###############################################################################
# All release operations rely on MRI                                          #
###############################################################################

##
# Release gem to Rubygems. VERSION required.
release: gem-build gem-push git-tag

##
# Build gem file
gem-build:
	@$(call mri-task, rake build)

##
# Push gem file to Rubygems
gem-push:
	@$(call mri-task, gem push $(internal_path)/pkg/iso8601-$(VERSION).gem)

##
# Tag version to git
git-tag:
	@$(GIT) tag v$(VERSION)

version:
	@echo "$(VERSION)"
