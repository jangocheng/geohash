all: build test lint

build: build-cmd

build-cmd:
	go build -v -i -o build/geohash ./cmd/geohash

test:
	mkdir -p build
	echo 'mode: set' > build/coverage.txt
	go list ./... | xargs -n1 -I{} sh -c\
	 'rm -f build/coverage.tmp && touch build/coverage.tmp &&\
	 go test -v -covermode=set -coverprofile=build/coverage.tmp {} &&\
	 tail -n +2 build/coverage.tmp >> build/coverage.txt'
	rm -f build/coverage.tmp
	go tool cover -html=build/coverage.txt -o=build/coverage.html

lint:
	go get -v -u github.com/alecthomas/gometalinter
	gometalinter --install --update --no-vendored-linters
	GOGC=800 gometalinter --enable-all -D dupl -D lll -D gas -D goconst -D gotype -D interfacer -D misspell -D safesql -D test -D testify -D vetshadow\
	 --tests --deadline=10m --concurrency=4 --enable-gc ./...

clean:
	rm -rf build

.PHONY: build build-cmd test lint clean