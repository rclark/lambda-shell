# lambda-shell

A Lambda function to run arbitrary shell commands on, and a helper tool for invoking it.

## Prerequisites

Make sure you have these tools installed:

- Terraform: `brew install terraform`
- Docker: [Docker for Mac](https://docs.docker.com/desktop/setup/install/mac-install/)
- AWS CLI: [Installation instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Go: `brew install go`

And make sure that your shell is able to acquire AWS credentials.

## Setup

One-time Terraform initialization:

```sh
make init
```

Whenever you want to create or update the Lambda function:

```sh
make apply
```

The [terraform folder](./terraform/) creates an ECR repository and a basic Lambda function. When you run `terraform apply`, it will build a Docker image from the [Dockerfile in the lambda folder](./lambda/Dockerfile). The built image will upload to ECR and that's what will run when you invoke the Lambda function.

## Run commands

```sh
# Run your single-line shell command...
make sh echo 'Hello World!'
```

The [cmd folder](./cmd/) contains a small application that invokes the Lambda function, providing it with a shell command to run.

## Launch in a VPC

Provide subnet IDs and at least one security group ID as variables in order to launch the Lambda function into a VPC. For example, create a file at
`terraform/terraform.tfvars`:

```hcl
subnet_ids = [
  "subnet-01897c054891bc6e5",
  "subnet-09e8dc434435b984e",
  "subnet-0b0b502ecdc4a7c7f"
]
security_group_ids = ["sg-071cc35db749dfd9c"]
```

And then run `make apply`.

## Play around

Adjust the [terraform configuration](./terraform/main.tf) and you can use your Lambda function to do other things.

Adjust the [Lambda function's Dockerfile](./lambda/Dockerfile) to install any special shell commands that you might want to leverage, e.g. `curl` or `psql`.
