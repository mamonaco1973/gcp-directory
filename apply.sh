#!/bin/bash

./check_env.sh
if [ $? -ne 0 ]; then
  echo "ERROR: Environment check failed. Exiting."
  exit 1
fi

cd 01-directory

terraform init
terraform apply -auto-approve

cd ..

cd 02-servers

terraform init
terraform apply -auto-approve

cd ..

