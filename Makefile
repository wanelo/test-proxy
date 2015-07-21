NO_COLOR=\033[0m
OK_COLOR=\033[32;01m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m
DEPS = $(go list -f '{{range .TestImports}}{{.}} {{end}}' ./...)
GO ?= $(shell echo go)

all: format deps build

deps:
	@echo "$(OK_COLOR)==> Installing dependencies$(NO_COLOR)"
	@$(GO) get -d -v ./...
	@echo $(DEPS) | xargs -n1 go get -d

update-deps:
	@echo "$(OK_COLOR)==> Updating all dependencies$(NO_COLOR)"
	@$(GO) get -d -v -u ./...
	@echo $(DEPS) | xargs -n1 go get -d -u

clean:
	@rm -rf bin/

format:
	@gofmt -l -w .

build:
	@mkdir -p bin/
	@echo "$(OK_COLOR)==> Building$(NO_COLOR)"
	@rm -rf bin/images
	@$(GO) build -o bin/test-proxy
	@echo "$(OK_COLOR)==> Building for solaris amd64$(NO_COLOR)"
	@mkdir -p bin/solaris
	@GOOS=solaris GOARCH=amd64 $(GO) build -o bin/solaris/test-proxy
	@echo "$(OK_COLOR)==> Building for darwin amd64$(NO_COLOR)"
	@mkdir -p bin/darwin
	@GOOS=darwin GOARCH=amd64 $(GO) build -o bin/darwin/test-proxy
	@echo "$(OK_COLOR)==> Building for linux amd64$(NO_COLOR)"
	@mkdir -p bin/linux
	@GOOS=linux GOARCH=amd64 $(GO) build -o bin/linux/test-proxy
	@echo "$(OK_COLOR)==> Compressing$(NO_COLOR)"
	@cd bin/solaris && tar -czvf test-proxy.tar.gz test-proxy
	@echo "$(OK_COLOR)==> Build OK$(NO_COLOR)"

release: build
	@echo "$(OK_COLOR)==> Uploading to manta$(NO_COLOR)"
	@mmkdir /$(MANTA_USER)/public/cache/test-proxy
	@mput -f bin/solaris/test-proxy /$(MANTA_USER)/public/cache/test-proxy/test-proxy-solaris
	@mput -f bin/darwin/test-proxy /$(MANTA_USER)/public/cache/test-proxy/test-proxy-darwin
	@mput -f bin/linux/test-proxy /$(MANTA_USER)/public/cache/test-proxy/test-proxy-linux
