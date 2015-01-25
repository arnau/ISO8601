TAG ?= latest
IMAGE_NAME ?= arnau/iso8601
IMAGE = $(IMAGE_NAME):$(TAG)
ORPHAN_IMAGES = `docker images -f 'dangling=true'`

build :
	docker build -t $(IMAGE) .

rmo :
	docker rmo $(ORPHAN_IMAGES)

rmi :
	docker rmi $(IMAGE)

run :
	docker run --rm -v $$(pwd):/usr/src/iso8601 $(IMAGE)
