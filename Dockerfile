FROM golang:1.23-bookworm AS builder
WORKDIR /src

# کل سورس رو کپی کن
COPY . .

# captcha.go رو حذف کن
RUN rm -f captcha.go

# go.mod حداقلی رو دستی بساز
RUN go mod init zai-api

# وابستگی‌ها رو دستی add کن (بدون tidy)
RUN go get github.com/labstack/echo/v4 || true
RUN go get github.com/labstack/echo/v4/middleware || true
RUN go get modernc.org/sqlite || true
RUN go get github.com/charmbracelet/bubbletea || true
RUN go get github.com/charmbracelet/bubbles || true
RUN go get github.com/charmbracelet/lipgloss || true

# بیلد کن — اگه وابستگی کم باشه، ارور می‌ده و لیستش رو می‌بینیم
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /zai-api main.go

# --- Runtime Image ---
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /zai-api /app/zai-api
RUN touch /app/tokens.sqlite
COPY --from=builder /src/tokens.sqlite* /app/tokens.sqlite

ENV HOST=0.0.0.0
ENV PORT=10000
ENV LOG_LEVEL=info

EXPOSE 10000
ENTRYPOINT ["/app/zai-api"]
