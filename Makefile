TAG ?= latest
IMAGE_NAME ?= arnau/iso8601
IMAGE = $(IMAGE_NAME):$(TAG)
ORPHAN_IMAGES = `docker images -f 'dangling=true'`

build :
	docker build -t $(IMAGE) .

rmo :
	docker rmi $(ORPHAN_IMAGES)

rmi :
	docker rmi $(IMAGE)

run :
	docker run -t --rm -v $$(pwd):/usr/src/iso8601 $(IMAGE)

shell :
	docker run -it --rm -v $$(pwd):/usr/src/iso8601 $(IMAGE) \
		pry -r ./lib/iso8601

gem :
	docker run -t --rm -v $$(pwd):/usr/src/iso8601 $(IMAGE) \
		bundle exec rake build

