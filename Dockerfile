FROM harbor.demo.appwork.com/library/golang:1.23.2-alpine as builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-s -w" -o main .

FROM scratch
WORKDIR /
COPY --from=builder /app/main .

EXPOSE 8080

ENTRYPOINT ["/main"]