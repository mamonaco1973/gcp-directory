# ==============================================================================
# main.tf
# ------------------------------------------------------------------------------
# Purpose:
#   - Configure the Google Cloud provider.
#   - Load credentials from a JSON file.
#   - Extract reusable values into local variables.
#
# Notes:
#   - Credentials file must exist at ../credentials.json.
#   - jsondecode() converts the JSON file into a map.
#   - Service account email is reused for IAM bindings.
# ==============================================================================

# ------------------------------------------------------------------------------
# Provider Configuration
# ------------------------------------------------------------------------------
# Configure the Google provider using project ID and credentials file.
provider "google" {
  project     = local.credentials.project_id
  credentials = file("../credentials.json")
}

# ------------------------------------------------------------------------------
# Local Variables
# ------------------------------------------------------------------------------
# Decode credentials JSON and extract commonly used values.
locals {
  credentials           = jsondecode(file("../credentials.json"))
  service_account_email = local.credentials.client_email
}