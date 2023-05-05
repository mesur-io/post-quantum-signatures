FROM golang:1.20.3-alpine

# Create directory for our app inside the container
WORKDIR /app

# Prepare dependencies
COPY go.mod .
COPY go.sum .
RUN go mod download

# Copy the source code
COPY *.go ./

# Build the binary and call it "dilithium"
RUN go build -o /dilithium .

EXPOSE 3000

CMD [ "/dilithium" ]