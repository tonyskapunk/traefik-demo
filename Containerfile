FROM golang:latest AS builder
COPY httpok/ .
RUN GOOS=linux CGO_ENABLED=0 go build -a -o /httpok main.go

FROM alpine:latest
RUN addgroup -S app \
    && adduser -S -g app app \
    && apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=builder httpok .
RUN chown -R app:app .
USER app
CMD ["./httpok"]
