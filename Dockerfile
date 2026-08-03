FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod init zai-api && go mod tidy
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -trimpath -o glm-api main.go

FROM alpine:latest
RUN apk add --no-cache ca-certificates tzdata
WORKDIR /app
COPY --from=builder /app/glm-api .
EXPOSE 3001
ENV PORT=3001
ENV HOST=0.0.0.0
CMD ["./glm-api"]
