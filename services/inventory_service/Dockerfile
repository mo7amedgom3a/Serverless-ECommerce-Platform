# Multi-stage build for Go Lambda
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum* ./
RUN go mod download

# Copy source code
COPY . .

# Build the Lambda binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o bootstrap cmd/lambda/main.go

# Final stage
FROM public.ecr.aws/lambda/provided:al2

# Copy the binary from builder
COPY --from=builder /app/bootstrap ${LAMBDA_RUNTIME_DIR}/bootstrap

# Set the CMD to your handler
CMD ["bootstrap"]
