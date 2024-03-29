resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
  lower   = true
  numeric = true
}

resource "aws_s3_bucket" "web_bucket" {
  bucket = "${var.s3_web_bucket_name}-${random_string.random.result}"
  
  tags = {
    Name        = "Static web bucket"
    Environment = "Dev"
  }
}

# Upload static website files to S3 bucket
resource "aws_s3_object" "website_content" {
  for_each = fileset("../website", "**/*")
  bucket   = aws_s3_bucket.web_bucket.id
  key      = "website/${each.key}"
  source   = "../website/${each.key}"
  content_type = lookup(local.content_type_map,
    reverse(split(".", each.value))[0],
  "binary/octet-stream")

  depends_on = [aws_s3_bucket.web_bucket]
}  

resource "aws_s3_bucket" "codepipeline" {
  bucket = "codepipeline-artifacts-${random_string.random.result}"
  force_destroy = true
  tags = {
    Name        = "CodePipeline artifacts bucket"
    Environment = "Dev"
  }
}