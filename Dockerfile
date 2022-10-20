FROM golang:1.19 as builder
# ENV DBADDR="db"
WORKDIR /usr/src/app

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .
RUN mkdir /go/bin/app
WORKDIR /go/bin/app
ENV GOPATH /go/bin/app
RUN CGO_ENABLED=1 GOOS=linux go build -ldflags="-s -w" -o /go/bin/app -v ./...

FROM alpine:latest as run
RUN apk --no-cache add ca-certificates
RUN apk add --no-cache libc6-compat 
# WORKDIR /root/
RUN addgroup -S app && adduser -S app -G app
COPY --from=builder --chown=app /go/bin/app /app
RUN chmod +x /app/*
USER app
RUN ls -al /app/kafka-consumer

CMD [ "/app/kafka-consumer" ]