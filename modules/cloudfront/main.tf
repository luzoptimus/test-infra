resource "aws_cloudfront_origin_access_identity" "default" {
  count = var.enable_s3 ? 1  : 0
  comment = format("%s-%s-cdn-ori-s3-%s", var.namespace, var.environment, var.project)
}

data "aws_iam_policy_document" "origin" {
  count = var.enable_s3 ? 1  : 0
  override_policy_documents = var.additional_bucket_policy

  statement {
    sid = "S3GetObjectForCloudFront"

    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::$${bucket_name}$${origin_path}*"]

    principals {
      type        = "AWS"
      identifiers = ["$${cloudfront_origin_access_identity_iam_arn}"]
    }
  }

  statement {
    sid = "S3ListBucketForCloudFront"

    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::$${bucket_name}"]

    principals {
      type        = "AWS"
      identifiers = ["$${cloudfront_origin_access_identity_iam_arn}"]
    }
  }
}

data "aws_iam_policy_document" "origin_website" {
  count = var.enable_s3 ? 1  : 0
  override_policy_documents = var.additional_bucket_policy

  statement {
    sid = "S3GetObjectForCloudFront"

    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::$${bucket_name}$${origin_path}*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

data "template_file" "default" {
  count = var.enable_s3 ? 1  : 0 ##cambio
  template = var.website_enabled ? data.aws_iam_policy_document.origin_website[0].json : data.aws_iam_policy_document.origin[0].json

  vars = {
    origin_path                               = coalesce(var.origin_path, "/")
    bucket_name                               = var.origin_bucket ##var.bucket
    cloudfront_origin_access_identity_iam_arn = aws_cloudfront_origin_access_identity.default[0].iam_arn
  }
}

resource "aws_s3_bucket_policy" "default" {
  count  = var.override_origin_bucket_policy && var.enable_s3 ? 1 : 0 ##
  bucket = var.origin_bucket ## var.bucket
  policy = data.template_file.default[0].rendered
}



data "aws_s3_bucket" "selected" {
  count = var.enable_s3 ? 1  : 0  ## cambio
  bucket = var.origin_bucket == "" ? var.static_s3_bucket : var.origin_bucket
}

locals {
  using_existing_origin = signum(length(var.origin_bucket)) == 1
}

resource "aws_cloudfront_distribution" "default" {
  count = var.enable_s3 ? 1  : 0 ## cambio
  enabled             = var.enabled
  is_ipv6_enabled     = var.ipv6_enabled
  comment             = var.comment
  default_root_object = var.default_root_object
  price_class         = var.price_class
  #depends_on          = [aws_s3_bucket.origin]

  dynamic "logging_config" {
    for_each = var.logging_enabled ? ["true"] : []
    content {
      include_cookies = var.log_include_cookies
      bucket          = var.bucket_logs
      prefix          = var.log_prefix
    }
  }

  aliases = var.acm_certificate_arn != "" ? var.aliases : []

  origin {
    domain_name = var.s3_bucket_domain_name ##var.origin_bucket_domain_name
    origin_id   = format("%s-%s-cdn-ori-s3-%s", var.namespace, var.environment, var.project)
    origin_path = var.origin_path

    dynamic "s3_origin_config" {
      for_each = ! var.website_enabled ? [1] : []
      content {
        origin_access_identity = aws_cloudfront_origin_access_identity.default[0].cloudfront_access_identity_path
      }
    }

    dynamic "custom_origin_config" {
      for_each = var.website_enabled ? [1] : []
      content {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2_2019"]
      }
    }
  }

  dynamic "origin" {
    for_each = var.custom_origins
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      origin_path = lookup(origin.value, "origin_path", "")
      custom_origin_config {
        http_port                = lookup(origin.value.custom_origin_config, "http_port", null)
        https_port               = lookup(origin.value.custom_origin_config, "https_port", null)
        origin_protocol_policy   = lookup(origin.value.custom_origin_config, "origin_protocol_policy", "https-only")
        origin_ssl_protocols     = lookup(origin.value.custom_origin_config, "origin_ssl_protocols", ["TLSv1.2"])
        origin_keepalive_timeout = lookup(origin.value.custom_origin_config, "origin_keepalive_timeout", 60)
        origin_read_timeout      = lookup(origin.value.custom_origin_config, "origin_read_timeout", 60)
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only" ##var.acm_certificate_arn == "" ? "" : "sni-only" 
    minimum_protocol_version       = var.minimum_protocol_version
    cloudfront_default_certificate = var.acm_certificate_arn == "" ? true : false
  }

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = format("%s-%s-cdn-ori-s3-%s", var.namespace, var.environment, var.project)
    compress         = var.compress
    trusted_signers  = var.trusted_signers

    forwarded_values {
      query_string = var.forward_query_string
      headers      = var.forward_header_values

      cookies {
        forward = var.forward_cookies
      }
    }

    viewer_protocol_policy = var.viewer_protocol_policy
    default_ttl            = var.default_ttl
    min_ttl                = var.min_ttl
    max_ttl                = var.max_ttl

    dynamic "lambda_function_association" {
      for_each = var.lambda_function_association
      content {
        event_type   = lambda_function_association.value.event_type
        include_body = lookup(lambda_function_association.value, "include_body", null)
        lambda_arn   = lambda_function_association.value.lambda_arn
      }
    }
    dynamic "function_association" {
        for_each = var.function_association
        content {
          event_type   = function_association.value.event_type
          function_arn   = aws_cloudfront_function.function[0].arn #function_association.value.function_arn
        }
      }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache

    content {
      path_pattern = ordered_cache_behavior.value.path_pattern

      allowed_methods  = ordered_cache_behavior.value.allowed_methods
      cached_methods   = ordered_cache_behavior.value.cached_methods
      target_origin_id = ordered_cache_behavior.value.target_origin_id == "" ? format("%s-%s-cdn-ori-beh-%s", var.namespace, var.environment, var.project) : ordered_cache_behavior.value.target_origin_id
      compress         = ordered_cache_behavior.value.compress
      trusted_signers  = var.trusted_signers

      forwarded_values {
        query_string = ordered_cache_behavior.value.forward_query_string
        headers      = ordered_cache_behavior.value.forward_header_values

        cookies {
          forward = ordered_cache_behavior.value.forward_cookies
        }
      }

      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
      default_ttl            = ordered_cache_behavior.value.default_ttl
      min_ttl                = ordered_cache_behavior.value.min_ttl
      max_ttl                = ordered_cache_behavior.value.max_ttl

      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda_function_association
        content {
          event_type   = lambda_function_association.value.event_type
          include_body = lookup(lambda_function_association.value, "include_body", null)
          lambda_arn   = lambda_function_association.value.lambda_arn
        }
      }
      dynamic "function_association" {
        for_each = ordered_cache_behavior.value.function_association
        content {
          event_type   = function_association.value.event_type
          function_arn   = function_association.value.function_arn
        }
      } 
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_response
    content {
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
      error_code            = custom_error_response.value.error_code
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
    }
  }

  web_acl_id          = var.web_acl_id
  wait_for_deployment = var.wait_for_deployment

  tags = var.tags
}

resource "aws_cloudfront_origin_access_identity" "cdn" {
  count = var.enable_s3  ? 0  : var.enabled ? 1 : 0
  comment = format("%s-%s-cdn-ori-id-%s", var.namespace, var.environment, var.project)
}


resource "aws_cloudfront_distribution" "cdn" {
  count = var.enable_s3  ? 0  : var.enabled ? 1 : 0
  enabled             = var.enabled
  is_ipv6_enabled     = var.ipv6_enabled
  comment             = var.comment
  ##default_root_object = var.default_root_object
  price_class         = var.price_class

  dynamic "logging_config" {
    for_each = var.logging_enabled ? ["true"] : []
    content {
      include_cookies = var.log_include_cookies
      bucket          = var.bucket_logs
      prefix          = var.log_prefix
    }
  }


  aliases = var.aliases

  dynamic "custom_error_response" {
    for_each = var.custom_error_response
    content {
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
      error_code            = custom_error_response.value.error_code
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
    }
  }


  origin {
    domain_name = var.origin_domain_name
    origin_id   = format("%s-%s-cdn-ori-id-%s", var.namespace, var.environment, var.project)
    origin_path = var.origin_path

    custom_origin_config {
      http_port                = var.origin_http_port
      https_port               = var.origin_https_port
      origin_protocol_policy   = var.origin_protocol_policy
      origin_ssl_protocols     = var.origin_ssl_protocols
      origin_keepalive_timeout = var.origin_keepalive_timeout
      origin_read_timeout      = var.origin_read_timeout
    }
  }
 

  dynamic "origin" {
    for_each = var.custom_origins
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      origin_path = lookup(origin.value, "origin_path", "")
      custom_origin_config {
        http_port                = lookup(origin.value.custom_origin_config, "http_port", null)
        https_port               = lookup(origin.value.custom_origin_config, "https_port", null)
        origin_protocol_policy   = lookup(origin.value.custom_origin_config, "origin_protocol_policy", "https-only")
        origin_ssl_protocols     = lookup(origin.value.custom_origin_config, "origin_ssl_protocols", ["TLSv1.2"])
        origin_keepalive_timeout = lookup(origin.value.custom_origin_config, "origin_keepalive_timeout", 60)
        origin_read_timeout      = lookup(origin.value.custom_origin_config, "origin_read_timeout", 60)
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = var.viewer_minimum_protocol_version
    cloudfront_default_certificate = var.acm_certificate_arn == "" ? true : false
  }

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = format("%s-%s-cdn-ori-id-%s", var.namespace, var.environment, var.project)
    compress         = var.compress

    forwarded_values {
      headers = var.forward_header_values
      query_string = var.forward_query_string

      cookies {
        forward           = var.forward_cookies
        whitelisted_names = var.forward_cookies_whitelisted_names
      }
    }

    viewer_protocol_policy = var.viewer_protocol_policy
    default_ttl            = var.default_ttl
    min_ttl                = var.min_ttl
    max_ttl                = var.max_ttl
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache

    content {
      path_pattern = ordered_cache_behavior.value.path_pattern

      allowed_methods  = ordered_cache_behavior.value.allowed_methods
      cached_methods   = ordered_cache_behavior.value.cached_methods
      target_origin_id = ordered_cache_behavior.value.target_origin_id == "" ? format("%s-%s-cdn-ori-beh-%s", var.namespace, var.environment, var.project) : ordered_cache_behavior.value.target_origin_id
      compress         = ordered_cache_behavior.value.compress
      trusted_signers  = var.trusted_signers

      forwarded_values {
        query_string = ordered_cache_behavior.value.forward_query_string
        headers      = ordered_cache_behavior.value.forward_header_values

        cookies {
          forward = ordered_cache_behavior.value.forward_cookies
        }
      }

      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
      default_ttl            = ordered_cache_behavior.value.default_ttl
      min_ttl                = ordered_cache_behavior.value.min_ttl
      max_ttl                = ordered_cache_behavior.value.max_ttl

      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda_function_association
        content {
          event_type   = lambda_function_association.value.event_type
          include_body = lookup(lambda_function_association.value, "include_body", null)
          lambda_arn   = lambda_function_association.value.lambda_arn
        }
      }
    }
  }

  #ordered_cache_behavior = var.cache_behavior

  web_acl_id = var.web_acl_id

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  tags = var.tags
}

 resource "aws_cloudfront_function" "function" {
 count =  var.enabled_functions && var.enabled ? 1 : 0
 name =  format("%s-%s-cdn-functions-%s", var.namespace, var.environment, var.project) 
 runtime = var.runtime
 comment = format("add functions en %s",  var.project)
 publish = var.publish
 code = var.code

 }