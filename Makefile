BASE_IMAGE_NAME ?= "imrehg/gentoo-aarch64-builder"
IMAGE_NAME ?= "gentoo-aarch64-build-setup"
CONTAINER_NAME ?= "gentoo-aarch64-build-task"
RPI_VERSION ?= "4"

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build-base: ## Docker build the Gentoo base image to work in
	@docker build --tag "${BASE_IMAGE_NAME}" .

base-pull: ## Pull (re-pull) the pre-built Gentoo base image from Docker Hub
	@docker pull "${BASE_IMAGE_NAME}"

base-push: ## Push the Gentoo base image to Docker Hub
	@docker push "${BASE_IMAGE_NAME}"

build-setup: ## Docker build the image being used for source build tasks
	@docker build --tag "${IMAGE_NAME}" -f Dockerfile.build .

stop: ## Stop running build container
	@docker rm -f ${CONTAINER_NAME} >/dev/null 2>&1 || true

compile: build-setup stop ## Build stuff for the default Raspberry Pi version (set by RPI_VERSION)
	@docker run -ti --name ${CONTAINER_NAME} -v "$(shell pwd)/build":/build -e "RPI_VERSION=${RPI_VERSION}" ${IMAGE_NAME} bash ./builder.sh

compile-rpi3: RPI_VERSION=3
compile-rpi3: compile ## Build stuff for Raspberry Pi 3

compile-rpi4: RPI_VERSION=4
compile-rpi4: compile ## Build stuff for Raspberry Pi 4
