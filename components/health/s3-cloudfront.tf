module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = replace(
    format(
      "%s-%s-%s-%s",
      var.project,
      var.environment,
      var.component,
      "s3-static",
    ),
    "_",
    "",
  )
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"
}

data "aws_iam_policy_document" "s3_policy" {
  # Origin Access Identities
  # statement {
  #   actions   = ["s3:GetObject",
  #                "s3:ListBucket" 
  #   ]
  #   resources = [module.s3_bucket.s3_bucket_arn,
  #   "${module.s3_bucket.s3_bucket_arn}/*"
  #   ]

  #   principals {
  #     type        = "AWS"
  #     identifiers = module.cloudfront.cloudfront_origin_access_identity_iam_arns
  #   }
  # }

  # Origin Access Controls
  statement {
    sid       = "AllowCloudFrontOAC"
    actions   = ["s3:GetObject",
                 "s3:ListBucket" 
    ]
    resources = [module.s3_bucket.s3_bucket_arn,
    "${module.s3_bucket.s3_bucket_arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.cloudfront.cloudfront_distribution_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy.json
}


module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"
  version = "v5.2.0"

  comment             = "Development environment"
  enabled             = true
  
  aliases                         = [var.domain_name_acm]
  default_root_object             = "index.html" 

  # create_origin_access_identity = true
  # origin_access_identities = {
  #   s3_oac = "My awesome CloudFront can access"
  # }

  create_origin_access_control = true
  origin_access_control = {
    "s3_oac-${var.environment}" = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }
  origin = {
    "s3_oac-${var.environment}" = { # with origin access control settings (recommended)
      domain_name           = module.s3_bucket.s3_bucket_bucket_regional_domain_name #"optimus-optimus-dev-develop-s3-static.s3.us-east-1.amazonaws.com"
      origin_access_control = "s3_oac-${var.environment}" # key in `origin_access_control`
      origin_id             = module.s3_bucket.s3_bucket_bucket_regional_domain_name #"s3_oac"
      
      origin_type = "s3"
      origin_path = "/ohc-healthcare-webapp/browser"

    #   s3_origin_config  = {
    #     origin_access_control = "s3_oac"
    #     http_port              = "80"
    #     https_port             = "443"
    #     origin_protocol_policy = "http-only"
    #     origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    #     }
     }
    alb = { # with origin access control settings (recommended)
    
      domain_name           = module.alb.dns_name
      origin_id             = "alb" # key in `origin_access_control`
      origin_type           = "custom"
      custom_origin_config  = {
        http_port              = "80"
        https_port             = "443"
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
        }
    }
  }

  default_cache_behavior = {
    cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id = module.s3_bucket.s3_bucket_bucket_regional_domain_name #"s3_oac" # key in `origin`
    viewer_protocol_policy = "allow-all"
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
    use_forwarded_values = false
    function_association = {
      viewer-request = {
        function_arn = aws_cloudfront_function.viewer.arn
      }
    }

  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/???-api/*"
      target_origin_id       = "alb"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      #use_forwarded_values = false
      query_string = true

      forward_query_string        = true
      forward_header_values       = ["Authorization"]
      forward_cookies             = "all"
      lambda_function_association = []
      function_association        = []
    }
  ]
  viewer_certificate = {
    acm_certificate_arn = module.acm_certificate_ingress_us_east_1.acm_certificate_arn
    cloudfront_default_certificate = false
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}


#########################################
# CloudFront function
#########################################

resource "aws_cloudfront_function" "viewer" {
  name    = format("%s-%s-function", var.environment, var.project)
  runtime = "cloudfront-js-2.0"
  code    = file("./function.js")
}