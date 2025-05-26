resource "aws_dynamodb_table" "this" {
  name         = var.name
  hash_key     = var.hash_key
  billing_mode = var.billing_mode
  table_class  = var.table_class

  dynamic "range_key" {
    for_each = var.range_key != null ? [1] : []
    content {
      value = var.range_key
    }
  }

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = try(global_secondary_index.value.range_key, null)
      projection_type = global_secondary_index.value.projection_type
    }
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  deletion_protection_enabled = var.deletion_protection_enabled

  tags = var.tags
}
