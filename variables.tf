variable "region" {
  description = "AWS region for the bucket"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Bucket name prefix; the workspace name is appended (e.g. my-site-cjtotten)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be lowercase letters, digits and hyphens, and start and end with a letter or digit."
  }
}
