jruby_image_name = $(image_name):jruby-9

##
# Run unit tests
jruby-test:
	@$(call jruby-task)

##
# Rubocop offence check
jruby-check:
	@$(call jruby-task, bundle exec rubocop lib spec)

##
# Open Ruby repl
jruby-repl:
	@$(call jruby-task, pry -r $(internal_path)/lib/iso8601)

jruby-shell:
	@$(call jruby-task, bash)

##
# Build docker image
jruby-build:
	@$(DOCKER) build -t $(jruby_image_name) -f Dockerfile.jruby .

jruby-clean:
	@$(DOCKER) rmi $(jruby_image_name)

jruby-push:
	@$(DOCKER) push $(jruby_image_name)

jruby-pull:
	@$(DOCKER) pull $(jruby_image_name)


define jruby-task
	$(DOCKER_TASK) $(volumes) $(jruby_image_name) $1
endef
