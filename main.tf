locals {
  # S3 names must be lowercase letters, digits, hyphens; map anything else in the workspace name to "-"
  workspace_slug   = replace(lower(terraform.workspace), "/[^a-z0-9-]/", "-")
  full_bucket_name = "${var.bucket_name}-${local.workspace_slug}"
}

resource "aws_s3_bucket" "site" {
  bucket = local.full_bucket_name

  lifecycle {
    precondition {
      condition     = length(local.full_bucket_name) <= 63
      error_message = "Bucket name '${local.full_bucket_name}' is longer than 63 characters; shorten bucket_name or the workspace name."
    }
  }
}

# Allow a public bucket policy (required for S3 website hosting)
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.site.arn}/*"
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.site]
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  etag         = filemd5("${path.module}/index.html")
  content_type = "text/html"
}
