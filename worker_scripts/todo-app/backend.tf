terraform {
  backend "s3" {
    bucket = "terraform-backend6"
    key    = "backend/ToDo-App.tfstate"
    region = "us-east-1"
    dynamodb_table = "agro-cd-db"
  }
}
