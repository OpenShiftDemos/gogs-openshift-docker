REPOSITORY_NAME := goern-docker-registry.bintray.io/goern
ARTIFACTORY_VERSION := 0.9.97
BUILD := 1

.PHONY: all push clean
all:
	docker build --tag $(REPOSITORY_NAME)/gogs:$(ARTIFACTORY_VERSION)-$(BUILD) .

push: all
	docker push $(REPOSITORY_NAME)/gogs:$(ARTIFACTORY_VERSION)-$(BUILD)

clean:
	docker rmi $(REPOSITORY_NAME)/gogs:$(ARTIFACTORY_VERSION)-$(BUILD)
