IMAGE_NAME := alexandrecarlton/eclim
ECLIM_VERSION := 2.7.1

all: build

build:
	docker build \
		--build-arg=ECLIM_VERSION=$(ECLIM_VERSION) \
		--tag=$(IMAGE_NAME) \
		.
.PHONY: build

tag:
	docker tag $(IMAGE_NAME) $(IMAGE_NAME):$(ECLIM_VERSION)
.PHONY: tag

test:
	./test.sh
.PHONY: test


