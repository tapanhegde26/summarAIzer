variable "function_name" {}
variable "lambda_role_arn" {}
variable "runtime" {
  default = "python3.12"
}
variable "lambda_zip_path" {}
variable "environment_vars" {
  type    = map(string)
  default = {}
}
