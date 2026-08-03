FROM golang:1.23-bookworm AS builder
WORKDIR /src
COPY go.mod ./
RUN go mod download
COPY . .
RUN go build -trimpath -ldflags="-s -w" -o /zai-api main.go

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates sqlite3 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /zai-api /app/zai-api
# tokens.sqlite از طریق GitHub Actions commit می‌شه
COPY tokens.sqlite /app/tokens.sqlite
EXPOSE 8080
ENV PORT=8080 HOST=0.0.0.0
ENTRYPOINT ["/app/zai-api"]
