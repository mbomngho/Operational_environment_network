
variable "region" {
  type        = string
  description = "aws region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "vpc cidr"
  default     = "10.0.0.0/16"
}

variable "pub_subnet_cidr" {
  type        = list(any)
  description = "pub subnet cidr"
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
}

variable "priv_subnet_cidr" {
  type        = list(any)
  description = "priv subnet cidr"
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "database_subnet_cidr" {
  type        = list(any) # or list(string)
  description = "database subnet cidr"
  default     = ["10.0.51.0/24", "10.0.53.0/24"]
}

# list