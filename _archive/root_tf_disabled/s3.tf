terraform {
  backend "s3" {
    bucket = "elpharco-webapp-terraform-tfstate01"
    key    = "devtest-github-actions.tfstate"
    region = "us-east-1"
  }
}