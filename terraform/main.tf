terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.93.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.3"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

resource "random_string" "tag" {
  length  = 8
  special = false
  keepers = {
    timestamp = timestamp()
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-shell"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy" "lambda_vpc" {
  name = "AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy" "lambda_basic_execution_role" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = data.aws_iam_policy.lambda_vpc.arn
}

resource "aws_iam_role_policy_attachment" "lambda_execution_role_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = data.aws_iam_policy.lambda_basic_execution_role.arn
}

resource "aws_ecr_repository" "lambda-shell" {
  name = "lambda-shell"
  force_delete = true
}

resource "aws_ecr_repository_policy" "lambda-access" {
  repository = aws_ecr_repository.lambda-shell.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
        ]
      }
    ]
  })
}

resource "null_resource" "docker_build_and_push" {
  depends_on = [aws_ecr_repository.lambda-shell]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      cd ../lambda
      docker build --platform linux/amd64 --provenance false --sbom false -t ${aws_ecr_repository.lambda-shell.repository_url}:${random_string.tag.result} .
      aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${aws_ecr_repository.lambda-shell.repository_url}
      docker push ${aws_ecr_repository.lambda-shell.repository_url}:${random_string.tag.result}
    EOT
  }
}

resource "aws_lambda_function" "lambda-shell" {
  depends_on    = [null_resource.docker_build_and_push]
  function_name = "lambda-shell"
  role          = aws_iam_role.lambda_execution_role.arn
  package_type  = "Image"

  image_uri = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${resource.aws_ecr_repository.lambda-shell.name}:${random_string.tag.result}"

  timeout = 300
}
