resource "aws_s3_bucket" "datalake-bucket" {
  bucket = "datalake-bucket-fukuda"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public-access-block" {
  bucket = aws_s3_bucket.datalake-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "allow_s3_policy" {
  statement {
    actions = ["s3:ListBucket", "s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
    resources = [
      "${aws_s3_bucket.datalake-bucket.arn}/*",
      "${aws_s3_bucket.datalake-bucket.arn}"
    ]
  }
}

resource "aws_iam_policy" "allow_s3_policy" {
  name = "datalake_allow_s3"

  policy = data.aws_iam_policy_document.allow_s3_policy.json
}
