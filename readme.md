# lambda-shell

A Lambda function to run arbitrary shell commands on, and a helper tool for invoking it.

## Prerequisites

Make sure you have these tools installed:

- Terraform
- Docker
- AWS CLI

And make sure that your shell is able to acquire AWS credentials.

## Setup

The [terraform folder](./terraform/) creates an ECR repository and a basic Lambda function. When you run `terraform apply`, it will build a Docker image from the [Dockerfile in the lambda folder](./lambda/Dockerfile). The built image will upload to ECR and that's what will run when you invoke the Lambda function.

```sh
cd terraform
terraform init
terraform apply
```

## Run commands

The [cmd folder](./cmd/) contains a small application that invokes the Lambda function, providing it with a shell command to run.

```
go run ./cmd echo 'Hello World!'
```

... is a really slow way to print that, courtesy of your new Lambda function!

## Play around

Adjust the [terraform configuration](./terraform/main.tf) and you can use your Lambda function to do other things. Putting the Lambda function into a VPC could allow your Lambda function to act as a kind of bastion host.

Adjust the [Lambda function's Dockerfile](./lambda/Dockerfile) to install any special shell commands that you might want to leverage, e.g. `curl` or `psql`.
