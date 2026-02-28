#!/bin/bash
# ==============================================================================
# apply.sh
# ------------------------------------------------------------------------------
# Purpose:
#   - Validate local environment prerequisites.
#   - Deploy Managed AD (Terraform) in 01-directory.
#   - Ensure admin credentials exist in Secret Manager:
#       - If missing, reset Managed AD admin password and store as a secret.
#
# Notes:
#   - Exits immediately on failures in prerequisite checks or Terraform apply.
#   - Requires: gcloud, terraform, jq, and authenticated gcloud context.
#   - Script currently exits before Phase 2 (02-servers) due to exit 0.
# ==============================================================================

# ------------------------------------------------------------------------------
# Pre-flight: Validate environment prerequisites
# ------------------------------------------------------------------------------
./check_env.sh
if [ $? -ne 0 ]; then
  echo "ERROR: Environment check failed. Exiting."
  exit 1
fi

# ------------------------------------------------------------------------------
# Phase 1: Deploy Managed AD (Terraform)
# ------------------------------------------------------------------------------
cd 01-directory

# Initialize Terraform for directory deployment.
terraform init

# Apply directory resources without interactive approval.
terraform apply -auto-approve
if [ $? -ne 0 ]; then
  echo "ERROR: Terraform apply failed in 01-directory. Exiting."
  exit 1
fi

# Return to repository root.
cd ..

# ------------------------------------------------------------------------------
# Admin Credentials: Ensure secret exists (reset if missing)
# ------------------------------------------------------------------------------
echo "NOTE: Retrieving domain password for mcloud.mikecloud.com."

# Attempt to read the latest admin credentials secret (ignore failures).
admin_credentials=$(gcloud secrets versions access latest \
  --secret="admin-ad-credentials-ad" 2> /dev/null || true)

# If secret is missing/empty, reset admin password and store new secret version.
if [[ -z "$admin_credentials" ]]; then
  echo "NOTE: Credentials need to be reset for 'mcloud.mikecloud.com'"

  # Reset Managed AD admin password and capture JSON output.
  output=$(gcloud active-directory domains reset-admin-password \
    "mcloud.mikecloud.com" --quiet --format=json)

  # Extract password from JSON.
  admin_password=$(echo "$output" | jq -r '.password')

  # Fail if password extraction produced empty output.
  if [[ -z "$admin_password" ]]; then
    echo "ERROR: Failed to retrieve admin password for mcloud.mikecloud.com"
    exit 1
  fi

  # Build username in DOMAIN\\user format.
  username="MCLOUD\\setupadmin"

  # Build JSON payload for Secret Manager.
  json_payload=$(jq -n \
    --arg username "$username" \
    --arg password "$admin_password" \
    '{username: $username, password: $password}')

  echo "NOTE: Storing new admin-ad-credentials-ad secret..."

  # Add a new secret version from stdin.
  echo "$json_payload" | gcloud secrets versions add \
    admin-ad-credentials-ad --data-file=-

  echo "NOTE: 'admin-ad-credentials-ad' secret has been updated."
else
  echo "NOTE: 'admin-ad-credentials-ad' secret already exists. No action taken."
fi

# ------------------------------------------------------------------------------
# Phase 2: Deploy servers joined to AD (Terraform)
# ------------------------------------------------------------------------------
cd 02-servers

# Initialize Terraform for server deployment.
terraform init

# Apply server resources without interactive approval.
terraform apply -auto-approve

# Return to repository root.
cd ..