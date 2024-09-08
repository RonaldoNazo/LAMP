# Https Endpoint
This module creates a public dns name for Application Load balancer endpoint!

## Usage

```hcl
module "https_endpoint" {
  source = "{PATH_TO_MODULE}/https"
  ##Required Variables
  application_name     = local.application_name
  application_lb_arn   = local.application_lb_arn
  alb_target_group_arn = local.alb_target_group_arn
  hosted_zone          = local.hosted_zone
  common_tags          = local.common_tags
}
```

Provide the name you want to set, and the endpoint you will redirect



