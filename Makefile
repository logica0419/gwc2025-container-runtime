PHONY: init
init:
	@go mod download
	@echo -e "{\n  \"name\": \"container\",\n  \"entry_point\": [\"/bin/bash\"],\
	\n  \"cgroup\": {\n    \"max_cpu_percent\": 100,\n    \"max_memory_mb\": 1024\n  },\
	\n  \"rootfs\": {\n    \"rootfs_path\": \"./rootfs\"\n  }\n}" > config.json

main: *.go
	go build -o main *.go

PHONY: run
run: main
	./main run bash

.ONESHELL: rootfs
rootfs:
	@if [ -z "$${IMAGE}" ]; then echo "Error: IMAGE環境変数が設定されていません"; exit	1; fi
	@mkdir -p rootfs
	@docker export $$(docker create "$${IMAGE}") | tar -C rootfs -xvf -

PHONY: clean
clean:
	@rm -f main
	@rm -rf rootfs
