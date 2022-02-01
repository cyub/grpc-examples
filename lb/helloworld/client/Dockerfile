FROM golang:1.16 as build-stage

WORKDIR /app

ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
ENV GOPATH /go/vendor
ENV GOPROXY https://goproxy.cn,direct
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"


COPY go.mod .
COPY go.sum .
COPY helloworld helloworld

RUN go mod download

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -v -o greeter_client ./helloworld/client/main.go

FROM alpine:latest
COPY --from=build-stage /app/greeter_client /usr/local/bin/greeter_client
RUN chmod +x /usr/local/bin/greeter_client
ENTRYPOINT ["greeter_client"]
