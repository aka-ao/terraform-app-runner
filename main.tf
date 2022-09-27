terraform {
  required_providers {
    aws = {
      version = ">= 3.42.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "ap-northeast-1"
}

resource "aws_apprunner_connection" "example" {
  connection_name = "aka-ao"
  provider_type   = "GITHUB"
}

resource "aws_apprunner_auto_scaling_configuration_version" "example" {
  auto_scaling_configuration_name = "example"

  max_concurrency = 2
  max_size        = 2
  min_size        = 1

  tags = {
    Name = "example-apprunner-autoscaling"
  }
}

resource "aws_apprunner_service" "example" {
  service_name = "example"
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.example.arn

  source_configuration {
    authentication_configuration {
      connection_arn = aws_apprunner_connection.example.arn
    }
    auto_deployments_enabled = false
    code_repository {
      code_configuration {
        code_configuration_values {
          build_command = "./mvnw clean package -DskipTests=true"
          port = "8080"
          runtime = "CORRETTO_11"
          start_command = "java -jar target/demo-0.0.1-SNAPSHOT.jar"
        }
        configuration_source = "API"
      }
      repository_url = var.github_repository
      source_code_version {
        type  = "BRANCH"
        value = "main"
      }
    }
  }

  tags = {
    Name = "example-apprunner-service"
  }

}
