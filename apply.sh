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

echo "NOTE: Retrieving domain password for mcloud.mikecloud.com."

admin_credentials=$(gcloud secrets versions access latest --secret="admin-ad-credentials" 2> /dev/null || true)
if [[ -z "$admin_credentials" ]]; then

   echo "NOTE:  Credentials need to be reset for 'mcloud.mikecloud.com'"
   output=$(gcloud active-directory domains reset-admin-password "mcloud.mikecloud.com" --quiet --format=json) 
   admin_password=$(echo "$output" | jq -r '.password')
   if [[ -z "$admin_password" ]]; then
    	echo "ERROR: Failed to retrieve admin password for mcloud.mikecloud.com"
    	exit 1
   fi

   username="MCLOUD\\\\setupadmin"
   json_payload=$(jq -n \
        --arg username "$username" \
        --arg password "$admin_password" \
        '{username: $username, password: $password}')

   echo "NOTE: Storing new admin-ad-credentials secret..."
   echo "$json_payload" | gcloud secrets versions add admin-ad-credentials --data-file=-
   echo "NOTE: 'admin-ad-credentials' secret has been updated."
else
   echo "NOTE: 'admin-ad-credentials' secret already exists. No action taken."
fi


cd 02-servers

terraform init
terraform apply -auto-approve

cd ..

