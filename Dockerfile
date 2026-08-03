FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY main.go captcha.go ./
RUN go mod init zai-api && go get modernc.org/sqlite && go mod tidy
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -trimpath -o glm-api .

FROM alpine:latest
RUN apk add --no-cache ca-certificates tzdata
WORKDIR /app
COPY --from=builder /app/glm-api .
EXPOSE 3001
ENV PORT=3001
ENV HOST=0.0.0.0
CMD ["./glm-api"]
