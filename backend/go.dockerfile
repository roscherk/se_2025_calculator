FROM golang:1.24.5-alpine3.22 AS builder

WORKDIR /app

COPY . .

RUN go install github.com/swaggo/swag/cmd/swag@latest
ENV PATH="${PATH}:$(go env GOPATH)/bin"

RUN go mod download
RUN swag init main.go

WORKDIR /app
RUN go build -o se_2025_calculator .

FROM alpine:3.22

WORKDIR /app

COPY --from=builder /app/se_2025_calculator .

EXPOSE 8000

CMD [ "./se_2025_calculator" ]