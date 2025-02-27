# ------------------------------------------------------------------------------
# IAM Role for Authenticated Users
# ------------------------------------------------------------------------------
resource "aws_iam_role" "auth_role" {
  name               = format("%s-auth-role", module.labels.id)
  assume_role_policy = data.aws_iam_policy_document.authenticated_assume.json
}

resource "aws_iam_role_policy" "auth_policy" {
  role   = aws_iam_role.auth_role.id
  policy = data.aws_iam_policy_document.authenticated.json
}

data "aws_iam_policy_document" "authenticated_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.identity_pool[0].id]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
  }
}

data "aws_iam_policy_document" "authenticated" {
  statement {
    effect    = "Allow"
    actions   = ["mobileanalytics:PutEvents", "cognito-sync:*", "es:*"]
    resources = ["*"]
  }
}

# ------------------------------------------------------------------------------
# IAM Role for Unauthenticated Users
# ------------------------------------------------------------------------------
resource "aws_iam_role" "unauth_role" {
  name               = format("%s-unauth-role", module.labels.id)
  assume_role_policy = data.aws_iam_policy_document.unauthenticated_assume.json
}

resource "aws_iam_role_policy" "unauth_policy" {
  role   = aws_iam_role.unauth_role.id
  policy = data.aws_iam_policy_document.unauthenticated.json
}

data "aws_iam_policy_document" "unauthenticated_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.identity_pool[0].id]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }
  }
}

data "aws_iam_policy_document" "unauthenticated" {
  statement {
    effect    = "Allow"
    actions   = ["mobileanalytics:PutEvents", "cognito-sync:*", "es:*"]
    resources = ["*"]
  }
}

# ------------------------------------------------------------------------------
# Attach IAM Roles to Cognito Identity Pool
# ------------------------------------------------------------------------------
resource "aws_cognito_identity_pool_roles_attachment" "identity_pool" {
  count            = var.enabled ? 1 : 0
  identity_pool_id = aws_cognito_identity_pool.identity_pool[0].id
  roles = {
    "authenticated"   = aws_iam_role.auth_role.arn
    "unauthenticated" = aws_iam_role.unauth_role.arn
  }
}
