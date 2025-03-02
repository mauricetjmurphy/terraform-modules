resource "aws_dynamodb_table" "this" {
  count = var.create_table ? 1 : 0

  name                        = var.name
  billing_mode                = var.billing_mode
  hash_key                    = var.hash_key
  range_key                   = var.range_key
  stream_enabled              = var.stream_enabled
  stream_view_type            = var.stream_enabled ? var.stream_view_type : null
  table_class                 = var.table_class
  deletion_protection_enabled = var.deletion_protection_enabled

  # ✅ **Include read/write capacity only if `billing_mode` is `PROVISIONED`**
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  ttl {
    enabled        = var.ttl_enabled
    attribute_name = var.ttl_attribute_name
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = lookup(local_secondary_index.value, "non_key_attributes", [])
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", [])

      # ✅ **Include read/write capacity only if `billing_mode` is `PROVISIONED`**
      read_capacity  = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "read_capacity", null) : null
      write_capacity = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "write_capacity", null) : null
    }
  }

  dynamic "replica" {
    for_each = var.replica_regions
    content {
      region_name            = replica.value.region_name
      kms_key_arn            = lookup(replica.value, "kms_key_arn", null)
      propagate_tags         = lookup(replica.value, "propagate_tags", null)
      point_in_time_recovery = lookup(replica.value, "point_in_time_recovery", null)
    }
  }

  server_side_encryption {
    enabled     = var.server_side_encryption_enabled
    kms_key_arn = var.server_side_encryption_kms_key_arn
  }

  tags = merge(var.tags, { "Name" = var.name })

  timeouts {
    create = lookup(var.timeouts, "create", null)
    delete = lookup(var.timeouts, "delete", null)
    update = lookup(var.timeouts, "update", null)
  }

  # ✅ Prevents unnecessary Terraform modifications to GSIs
  lifecycle {
    ignore_changes = [billing_mode, global_secondary_index]
  }
}
