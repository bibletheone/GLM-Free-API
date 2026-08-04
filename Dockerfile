FROM golang:1.23-bookworm AS builder
WORKDIR /src

# go.mod رو کپی کن و dependencies رو دانلود کن
COPY go.mod go.sum* ./
RUN go mod download

# کل سورس رو کپی کن
COPY . .

# فقط main.go رو build کن — captcha.go رو excludes کن
# CGO_ENABLED=0 چون modernc.org/sqlite استفاده می‌کنه (pure Go، no CGO)
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /zai-api main.go

# --- Runtime image ---
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
# binary رو کپی کن
COPY --from=builder /zai-api /app/zai-api
# tokens.sqlite رو از repo کپی کن (GitHub Actions این فایل رو آپدیت می‌کنه)
COPY tokens.sqlite /app/tokens.sqlite

# Render پورت رو از env var PORT می‌گیره
ENV HOST=0.0.0.0
ENV PORT=10000
ENV LOG_LEVEL=info

EXPOSE 10000
ENTRYPOINT ["/app/zai-api"]
