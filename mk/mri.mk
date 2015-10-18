mri_image_name = $(image_name):mri-2.2.3

##
# Run unit tests
mri-test:
	@$(call mri-task)

##
# Rubocop offence check
mri-check:
	@$(call mri-task, bundle exec rubocop lib spec)

##
# Open Ruby repl
mri-repl:
	@$(call mri-task, pry -r $(internal_path)/lib/iso8601)

mri-shell:
	@$(call mri-task, bash)

##
# Build docker image
mri-build:
	@$(DOCKER) build -t $(rbx_image_name) -f Dockerfile .

mri-clean:
	@$(DOCKER) rmi $(mri_image_name)

mri-push:
	@$(DOCKER) push $(mri_image_name)

mri-pull:
	@$(DOCKER) pull $(mri_image_name)


define mri-task
	$(DOCKER_TASK) $(volumes) $(mri_image_name) $1
endef
