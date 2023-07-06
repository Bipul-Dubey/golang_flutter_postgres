FROM golang:1.20 As build-stage

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /go_work

FROM gcr.io/distroless/base-debian11 As build-release-stage

WORKDIR /

COPY .env ./
COPY --from=build-stage /go_work /go_work

ENTRYPOINT ["/go_work"]
