rbx_image_name = $(image_name):rbx-2.5.8

##
# Run unit tests
rbx-test:
	@$(call rbx-task)

##
# Rubocop offence check
rbx-check:
	@$(call rbx-task, bundle exec rubocop lib spec)

##
# Open Ruby repl
rbx-repl:
	@$(call rbx-task, pry -r $(internal_path)/lib/iso8601)

rbx-shell:
	@$(call rbx-task, bash)

##
# Build docker image
rbx-build:
	@$(DOCKER) build -t $(rbx_image_name) -f Dockerfile.rbx .

rbx-clean:
	@$(DOCKER) rmi $(rbx_image_name)

rbx-push:
	@$(DOCKER) push $(rbx_image_name)

rbx-pull:
	@$(DOCKER) pull $(rbx_image_name)


define rbx-task
	$(DOCKER_TASK) $(volumes) $(rbx_image_name) $1
endef
