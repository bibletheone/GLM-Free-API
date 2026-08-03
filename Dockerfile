FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY main.go captcha.go ./
RUN printf 'module zai-api\n\ngo 1.22\n\nrequire modernc.org/sqlite v1.34.1\n' > go.mod
RUN go mod download
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -trimpath -o glm-api main.go

FROM alpine:latest
RUN apk add --no-cache ca-certificates tzdata
WORKDIR /app
COPY --from=builder /app/glm-api .
EXPOSE 3001
ENV PORT=3001
ENV HOST=0.0.0.0
CMD ["./glm-api"]
