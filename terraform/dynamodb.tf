resource "aws_dynamodb_table" "entries" {
  name         = "ccc-entries"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "entryId"

  attribute {
    name = "entryId"
    type = "S"
  }

  tags = {
    Name = "ccc-entry-table"
  }
}