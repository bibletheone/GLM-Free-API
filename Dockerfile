FROM golang:1.23-bookworm AS builder
WORKDIR /src

# کل سورس رو کپی کن
COPY . .

# captcha.go رو حذف کن — به Playwright نیاز داره و توی سرور کاربردی نداره
RUN rm -f captcha.go

# go.mod رو دستی بساز با تنها وابستگی واقعی
RUN printf 'module zai-api\n\ngo 1.23\n\nrequire modernc.org/sqlite v1.34.5\n' > go.mod

# وابستگی‌های transitif رو دانلود کن
RUN go mod tidy

# بیلد کن
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /zai-api main.go

# --- Runtime Image ---
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# باینری رو کپی کن
COPY --from=builder /zai-api /app/zai-api

# tokens.sqlite — اگه توی repo نبود، یه فایل خالی بساز
RUN touch /app/tokens.sqlite
COPY --from=builder /src/tokens.sqlite* /app/tokens.sqlite

ENV HOST=0.0.0.0
ENV PORT=10000
ENV LOG_LEVEL=info

EXPOSE 10000
ENTRYPOINT ["/app/zai-api"]
