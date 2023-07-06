# syntax=docker/dockerfile:1
# for postgres container 
# docker run --name postgresDB --network mynet -e POSTGRES_PASSWORD=1234 -d postgres    
FROM golang:1.20

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY .env ./
COPY *.go ./

ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=1234
ENV POSTGRES_DB=postgres
ENV PGHOST=postgresDB
ENV PGPORT=5432

RUN CGO_ENABLED=0 GOOS=linux go build -o /go_work

CMD ["/go_work"]
