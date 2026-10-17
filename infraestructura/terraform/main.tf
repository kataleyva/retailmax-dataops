provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "datos" {
  bucket = "retailmax-datos-${var.entorno}"
}
