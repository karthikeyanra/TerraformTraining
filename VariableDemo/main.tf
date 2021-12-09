

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.68.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-2"
}

variable "instance_type" {
    description = "enter instance type"
    type = string
    validation {
      condition = substr(var.instance_type,0,3)=="t2."
      error_message = "Instance type must be t2."
    }

  
}

resource "aws_instance" "mywebserver" {
    ami = "ami-002068ed284fb165b"
    instance_type = var.instance_type

}