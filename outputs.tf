output "website_url" {
  description = "S3 static website endpoint (HTTP only)"
  value       = "http://${aws_s3_bucket_website_configuration.site.website_endpoint}"
}
