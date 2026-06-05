resource "aws_s3_bucket" "ccc_images" {
  bucket = "ccc-images-abila"

  tags = {
    Name        = "ccc-images-abila"
  }
}

resource "aws_s3_bucket_versioning" "ccc_images_versioning" {
  bucket = aws_s3_bucket.ccc_images.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ccc_images_encryption" {
  bucket = aws_s3_bucket.ccc_images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "ccc_images_public_access" {
  bucket = aws_s3_bucket.ccc_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}