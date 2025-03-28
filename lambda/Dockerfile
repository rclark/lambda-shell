FROM public.ecr.aws/lambda/go AS build

RUN yum install -y curl tar gzip git
RUN curl -sSL https://go.dev/dl/go1.24.1.linux-amd64.tar.gz -o go1.24.1.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.24.1.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin
RUN go env -w GOPROXY=https://proxy.golang.org

WORKDIR /go/src/app

ADD go.mod go.sum ./
RUN go mod download

ADD ./ ./
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o /go/bin/app

FROM public.ecr.aws/lambda/go

COPY --from=build /go/bin/app /${LAMBDA_TASK_ROOT}

ENTRYPOINT [ "./app" ]
