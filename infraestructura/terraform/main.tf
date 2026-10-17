terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  etiquetas = {
    Proyecto = "retailmax"
    Entorno  = var.entorno
  }
}

# Bucket S3 para datos de staging (todos los entornos)
resource "aws_s3_bucket" "staging" {
  bucket = "retailmax-staging-${var.entorno}"
  tags   = local.etiquetas
}

resource "aws_s3_bucket_versioning" "staging" {
  bucket = aws_s3_bucket.staging.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_instance" "dev" {
  count                = var.entorno == "dev" ? 1 : 0
  ami                  = var.ami_id
  instance_type        = var.tipo_instancia
  iam_instance_profile = aws_iam_instance_profile.etl.name
  tags                 = merge(local.etiquetas, { Name = "retailmax-ec2-dev" })
}

resource "aws_db_instance" "prod" {
  count                     = var.entorno == "prod" ? 1 : 0
  identifier                = "retailmax-db-prod"
  engine                    = "postgres"
  instance_class            = "db.t3.micro"
  allocated_storage         = 20
  db_name                   = "retailmax"
  username                  = var.db_usuario
  password                  = var.db_password
  storage_encrypted         = true
  publicly_accessible       = false
  backup_retention_period   = 7
  deletion_protection       = true
  final_snapshot_identifier = "retailmax-db-prod-final"
  tags                      = local.etiquetas
}

resource "aws_iam_role" "etl" {
  name = "retailmax-etl-${var.entorno}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = local.etiquetas
}

resource "aws_iam_role_policy" "solo_staging" {
  name = "acceso-solo-bucket-staging"
  role = aws_iam_role.etl.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.staging.arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "${aws_s3_bucket.staging.arn}/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "etl" {
  name = "retailmax-etl-${var.entorno}"
  role = aws_iam_role.etl.name
}