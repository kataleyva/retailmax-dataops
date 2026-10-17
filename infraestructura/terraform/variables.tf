variable "entorno" {
  description = "Entorno a desplegar: dev, qa o prod"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "prod"], var.entorno)
    error_message = "El entorno debe ser dev, qa o prod."
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ami_id" {
  description = "AMI de la instancia EC2 de DEV"
  type        = string
  default     = "ami-0123456789abcdef0" # reemplazar por una AMI real
}

variable "tipo_instancia" {
  type    = string
  default = "t3.micro"
}

variable "db_usuario" {
  type    = string
  default = "admin_retailmax"
}

variable "db_password" {
  description = "Se pasa con la variable de entorno TF_VAR_db_password, nunca en el código"
  type        = string
  sensitive   = true
  default     = null
}