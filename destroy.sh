#!/bin/bash
# ==============================================================================
# destroy.sh
# ------------------------------------------------------------------------------
# Purpose:
#   - Tear down AD-connected servers (02-servers).
#   - Tear down Managed AD directory (01-directory).
#
# Notes:
#   - Destruction order is important:
#       1) Destroy servers first.
#       2) Destroy directory last.
#   - Uses -auto-approve to avoid interactive confirmation.
#   - Assumes terraform and gcloud are already authenticated.
# ==============================================================================

# ------------------------------------------------------------------------------
# Phase 1: Destroy AD-connected servers
# ------------------------------------------------------------------------------
cd 02-servers

# Initialize Terraform for server module.
terraform init

# Destroy server resources without interactive approval.
terraform destroy -auto-approve

# Return to repository root.
cd ..

# ------------------------------------------------------------------------------
# Phase 2: Destroy Managed AD directory
# ------------------------------------------------------------------------------
cd 01-directory

# Initialize Terraform for directory module.
terraform init

# Destroy directory resources without interactive approval.
terraform destroy -auto-approve

# Return to repository root.
cd ..