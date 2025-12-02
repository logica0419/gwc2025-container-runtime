main: *.go
	go build -o main *.go

PHONY: run
run: main
	./main run bash
