FROM golang:1.23-bookworm AS builder
WORKDIR /src

# کل سورس رو کپی کن
COPY . .

# captcha.go رو حذف کن چون به Playwright نیاز داره و تو سرور کاربردی نداره
RUN rm -f captcha.go

# اگه go.mod وجود نداشت، خودش بساز
RUN if [ ! -f go.mod ]; then go mod init zai-api; fi

# وابستگی‌ها رو دانلود و تنظیم کن (حالا فقط وابستگی‌های main.go رو می‌گیره)
RUN go mod tidy

# فقط main.go رو بیلد کن
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /zai-api main.go

# --- Runtime Image ---
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# باینری رو کپی کن
COPY --from=builder /zai-api /app/zai-api

# tokens.sqlite رو کپی کن (اگه نبود، یه فایل خالی بساز که سرور کرش نکنه)
RUN touch /app/tokens.sqlite
COPY --from=builder /src/tokens.sqlite* /app/tokens.sqlite

# تنظیمات پیش‌فرض
ENV HOST=0.0.0.0
ENV PORT=10000
ENV LOG_LEVEL=info

EXPOSE 10000
ENTRYPOINT ["/app/zai-api"]
