ARG BIN=demo.bin

FROM golang:1.20-alpine as Builder
ARG BIN
ARG VERSION
WORKDIR /app
COPY . .
RUN go build -o $BIN -ldflags="-X 'main.version=$VERSION'"

FROM alpine:3.18.2
ARG BIN
WORKDIR /app
COPY --from=Builder /app/$BIN .
ENV BINARY=$BIN
CMD ["sh", "-c", "/app/${BINARY}"]