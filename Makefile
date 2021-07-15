# Go parameters
GOCMD?=go
GOBUILD?=$(GOCMD) build
GOCLEAN?=$(GOCMD) clean
GOTEST?=$(GOCMD) test
GOGET?=$(GOCMD) get
GOBIN?=$(GOPATH)/bin

# Build parameters
OUT?=./out
DOCKER_TMP?=$(OUT)/docker_temp/
#DOCKER_TAG?=aeraki/eureka2istio:latest
DOCKER_TAG?=huanghuangzym/eureka2istio:latest
#DOCKER_TAG_E2E?=aeraki/eureka2istio:`git log --format="%H" -n 1`
DOCKER_TAG_E2E?=huanghuangzym/eureka2istio:`git log --format="%H" -n 1`
BINARY_NAME?=$(OUT)/eureka2istio
BINARY_NAME_DARWIN?=$(BINARY_NAME)-darwin
MAIN_PATH_CONSUL_MCP=./cmd/eureka2istio/main.go


# Run go fmt against code
fmt:
	go fmt ./...
# Run go vet against code
vet:
	go vet ./...


build: fmt
	CGO_ENABLED=0 GOOS=linux  $(GOBUILD) -o $(BINARY_NAME) $(MAIN_PATH_CONSUL_MCP)
build-mac:
	CGO_ENABLED=0 GOOS=darwin  $(GOBUILD) -o $(BINARY_NAME_DARWIN) $(MAIN_PATH_CONSUL_MCP)
docker-build: build
	rm -rf $(DOCKER_TMP)
	mkdir $(DOCKER_TMP)
	cp ./docker/Dockerfile $(DOCKER_TMP)
	cp $(BINARY_NAME) $(DOCKER_TMP)
	docker build -t $(DOCKER_TAG) $(DOCKER_TMP) --load
	rm -rf $(DOCKER_TMP)
docker-build-e2e: build
	rm -rf $(DOCKER_TMP)
	mkdir $(DOCKER_TMP)
	cp ./docker/Dockerfile $(DOCKER_TMP)
	cp $(BINARY_NAME) $(DOCKER_TMP)
	docker build -t $(DOCKER_TAG_E2E) $(DOCKER_TMP)
docker-push:
	docker push $(DOCKER_TAG)
style-check:
	gofmt -l -d ./
	goimports -l -d ./
lint:
	golint ./...
	golangci-lint  run -v --tests="false"
test:
	go test --race ./...
clean:
	rm -rf $(OUT)

.PHONY: build docker-build docker-push clean
