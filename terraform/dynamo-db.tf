resource "aws_dynamodb_table" "price-dynamodb-table" {
  name           = var.PRICE_TABLE
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "NAME"

  attribute {
    name = "NAME"
    type = "S"
  }

//  ttl {
//    attribute_name = "TimeToExist"
//    enabled        = false
//  }

  tags = {
    Name        = "price-dynamodb-table"
  }
}