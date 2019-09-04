IMAGE_NAME ?= "gentoo-aarch64-build-setup"
CONTAINER_NAME ?= "gentoo-aarch64-build-task"
# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build-setup: ## Docker build the image being used for source build tasks
	@docker build --tag "${IMAGE_NAME}" -f Dockerfile.build .
	# @docker run -ti --name ${CONTAINER_NAME} -v $(pwd)/build:/build

compile-rpi3: build-setup ## Build stuff for Raspberry Pi 4
	@docker run -ti --name ${CONTAINER_NAME} -v $(pwd)/build:/build -e "RPI_VERSION=3" ${IMAGE_NAME}

compile-rpi4: build-setup ## Build stuff for Raspberry Pi 3
	@docker run -ti --name ${CONTAINER_NAME} -v $(pwd)/build:/build -e "RPI_VERSION=4" ${IMAGE_NAME}

stop: ## Stop running build container
	@docker rm -f ${CONTAINER_NAME} >/dev/null 2>&1 || true