# ==============================================================================
# accounts.tf
# ------------------------------------------------------------------------------
# Purpose:
#   - Generate per-user random passwords.
#   - Store AD creds (username/password) in GCP Secret Manager.
#   - Grant a service account secretAccessor access to all secrets.
#
# Notes:
#   - Passwords are 24 chars with special chars limited to: !@#$%
#   - Credentials are stored as JSON in Secret Manager secret versions.
#   - IAM binding uses for_each over a local list of secret_ids.
# ==============================================================================

# ------------------------------------------------------------------------------
# User: John Smith
# ------------------------------------------------------------------------------

# Generate a random password for John Smith.
resource "random_password" "jsmith_password" {
  length           = 24
  special          = true
  override_special = "!@#$%"
}

# Create Secret Manager secret to store John Smith's AD credentials.
resource "google_secret_manager_secret" "jsmith_secret" {
  secret_id = "jsmith-ad-credential-ad"

  replication {
    auto {}
  }
}

# Store John Smith's AD credentials as JSON in a secret version.
resource "google_secret_manager_secret_version" "jsmith_secret_version" {
  secret      = google_secret_manager_secret.jsmith_secret.id
  secret_data = jsonencode({
    username = "MCLOUD\\jsmith"
    password = random_password.jsmith_password.result
  })
}

# ------------------------------------------------------------------------------
# User: Emily Davis
# ------------------------------------------------------------------------------

# Generate a random password for Emily Davis.
resource "random_password" "edavis_password" {
  length           = 24
  special          = true
  override_special = "!@#$%"
}

# Create Secret Manager secret to store Emily Davis' AD credentials.
resource "google_secret_manager_secret" "edavis_secret" {
  secret_id = "edavis-ad-credentials-ad"

  replication {
    auto {}
  }
}

# Store Emily Davis' AD credentials as JSON in a secret version.
resource "google_secret_manager_secret_version" "edavis_secret_version" {
  secret      = google_secret_manager_secret.edavis_secret.id
  secret_data = jsonencode({
    username = "MCLOUD\\edavis"
    password = random_password.edavis_password.result
  })
}

# ------------------------------------------------------------------------------
# User: Raj Patel
# ------------------------------------------------------------------------------

# Generate a random password for Raj Patel.
resource "random_password" "rpatel_password" {
  length           = 24
  special          = true
  override_special = "!@#$%"
}

# Create Secret Manager secret to store Raj Patel's AD credentials.
resource "google_secret_manager_secret" "rpatel_secret" {
  secret_id = "rpatel-ad-credentials-ad"

  replication {
    auto {}
  }
}

# Store Raj Patel's AD credentials as JSON in a secret version.
resource "google_secret_manager_secret_version" "rpatel_secret_version" {
  secret      = google_secret_manager_secret.rpatel_secret.id
  secret_data = jsonencode({
    username = "MCLOUD\\rpatel"
    password = random_password.rpatel_password.result
  })
}

# ------------------------------------------------------------------------------
# User: Amit Kumar
# ------------------------------------------------------------------------------

# Generate a random password for Amit Kumar.
resource "random_password" "akumar_password" {
  length           = 24
  special          = true
  override_special = "!@#$%"
}

# Create Secret Manager secret to store Amit Kumar's AD credentials.
resource "google_secret_manager_secret" "akumar_secret" {
  secret_id = "akumar-ad-credentials-ad"

  replication {
    auto {}
  }
}

# Store Amit Kumar's AD credentials as JSON in a secret version.
resource "google_secret_manager_secret_version" "akumar_secret_version" {
  secret      = google_secret_manager_secret.akumar_secret.id
  secret_data = jsonencode({
    username = "MCLOUD\\akumar"
    password = random_password.akumar_password.result
  })
}

# ------------------------------------------------------------------------------
# Admin secret (container only; no version defined here)
# ------------------------------------------------------------------------------

# Create Secret Manager secret intended to hold admin AD credentials.
resource "google_secret_manager_secret" "admin_secret" {
  secret_id = "admin-ad-credentials-ad"

  replication {
    auto {}
  }
}

# ------------------------------------------------------------------------------
# IAM access: allow the service account to read all created secrets
# ------------------------------------------------------------------------------

# List of all Secret Manager secret_ids (used for IAM binding iteration).
locals {
  secrets = [
    google_secret_manager_secret.jsmith_secret.secret_id,
    google_secret_manager_secret.edavis_secret.secret_id,
    google_secret_manager_secret.rpatel_secret.secret_id,
    google_secret_manager_secret.akumar_secret.secret_id,
    google_secret_manager_secret.admin_secret.secret_id
  ]
}

# Grant the service account Secret Manager accessor role on each secret.
resource "google_secret_manager_secret_iam_binding" "secret_access" {
  for_each  = toset(local.secrets) # Loop through each secret_id in locals.
  secret_id = each.key
  role      = "roles/secretmanager.secretAccessor"

  members = [
    "serviceAccount:${local.service_account_email}" # Existing service account.
  ]
}