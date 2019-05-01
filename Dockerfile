FROM golang:1.12.4-alpine3.9 AS build-env

ENV USER root
WORKDIR /go/src/github.com/cloudflare
COPY . .

# restore all deps and build
RUN apk update && \
    apk add git make gcc libc-dev
RUN git clone https://github.com/cloudflare/cfssl.git $GOPATH/src/github.com/cloudflare/cfssl && \
    cd $GOPATH/src/github.com/cloudflare/cfssl && \
    make $GOPATH/src/github.com/cloudflare/cfssl && \
    go get github.com/cloudflare/cfssl_trust/... && \
    go get github.com/GeertJohan/go.rice/rice && \
    rice embed-go -i=./cli/serve && \ 
    cp -R /go/src/github.com/cloudflare/cfssl_trust /etc/cfssl && \
    go install ./cmd/...

FROM alpine:3.9
WORKDIR /go/bin
COPY --from=build-env /go/bin/cfssl /go/bin/

EXPOSE 80

ENTRYPOINT ["/go/bin/cfssl"]
CMD ["--help"]
