variable "region" {
  default = "ap-northeast-1"
}

variable "project" {
  default = "guacamole-poc"
}

variable "guacamole_image" {
  description = "ECR image URI for guacamole"
  type        = string
}
