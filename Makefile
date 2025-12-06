PHONY: init
init:
	@go mod download
	@echo "{\n  \"name\": \"container\",\n  \"entry_point\": [\"/bin/bash\"],\
	\n  \"cgroup\": {\n    \"max_cpu_percent\": 100,\n    \"MaxMemoryMB\": 1024\n  },\
	\n  \"rootfs\": {\n    \"rootfs_path\": \"./root\"\n  }\n}" > config.json

main: *.go
	go build -o main *.go

PHONY: run
run: main
	./main run bash

rootfs:
	rm -rf root
	mkdir root
	docker export $$(docker create "$${IMAGE}") | tar -C root -xvf -
