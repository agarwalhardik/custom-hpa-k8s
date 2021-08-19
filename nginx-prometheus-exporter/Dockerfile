FROM nginx:latest as base

RUN mkdir -p /var/www/cache
RUN mkdir -p /var/www/html
RUN mkdir -p /etc/nginx/templates
COPY nginx-proxy/default.conf.template /etc/nginx/templates/
COPY nginx-proxy/start.sh /usr/bin
RUN chmod +x /usr/bin/start.sh
ENTRYPOINT /usr/bin/start.sh

FROM golang:1.12 as builder

ENV VERSION=001
WORKDIR /go/src/github.com/nginxinc/nginx-prometheus-exporter
COPY *.go ./
COPY vendor ./vendor
COPY go.mod go.sum ./
COPY collector ./collector
COPY client ./client
RUN GO111MODULE=on CGO_ENABLED=0 GOOS=linux go build -mod=vendor -a -installsuffix cgo -ldflags "-X main.version=${VERSION}" -o exporter .

FROM  base

COPY --from=builder /go/src/github.com/nginxinc/nginx-prometheus-exporter/exporter /usr/bin/
COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh
