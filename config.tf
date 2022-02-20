terraform {
  backend "s3" {
    bucket  = "rates-statefiles"
    key     = "ratesv1.0"
    region  = "eu-west-1"
    encrypt = true
  }
}
