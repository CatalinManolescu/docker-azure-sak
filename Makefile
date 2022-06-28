#!make

# terraform releases https://releases.hashicorp.com/terraform/
root_path := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

include $(root_path)/.env

docker_repo = catalinm/azure-sak

build:
	echo "== building image with ubuntu '${UBUNTU_VERSION}' and terraform '${TERRAFORM_VERSION}'";\
	docker build --pull \
		--build-arg PLATFORM=${PLATFORM} --build-arg UBUNTU_VERSION=${UBUNTU_VERSION} \
		--build-arg TERRAFORM_VERSION=${TERRAFORM_VERSION} --build-arg HELM_VERSION=${HELM_VERSION} \
		-f $(root_path)/Dockerfile -t $(docker_repo):ubuntu-${UBUNTU_VERSION}-tf${TERRAFORM_VERSION}  $(root_path)

scan:
	docker scan $(docker_repo):ubuntu-${UBUNTU_VERSION}${PLATFORM}-tf${TERRAFORM_VERSION}

push:
	docker push $(docker_repo):ubuntu-${UBUNTU_VERSION}${PLATFORM}-tf${TERRAFORM_VERSION}

clean:
	docker rmi $(docker_repo):ubuntu-${UBUNTU_VERSION}${PLATFORM}-tf${TERRAFORM_VERSION}