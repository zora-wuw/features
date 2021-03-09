#!/usr/bin/env bash

config_file=$1
container_name=$2
file_array=$3

swift_username=$(awk -F "=" '/Username/ {print $2}' $config_file)
swift_pwd=$(awk -F "=" '/Psword/ {print $2}' $config_file)
swift_project_id=$(awk -F "=" '/OS-Project-ID/ {print $2}' $config_file)
swift_project_name=$(awk -F "=" '/OS-Project-Name/ {print $2}' $config_file)
swift_region_name=$(awk -F "=" '/OS-Region-Name/ {print $2}' $config_file)
swift_user_domain_name=$(awk -F "=" '/OS-User-Domain-Name/ {print $2}' $config_file)

for file in $file_array; do
  swift --os-username $swift_username --os-password $swift_pwd --os-auth-url https://keystone.rc.nectar.org.au:5000/v3/ --os-region-name $swift_region_name --os-project-id $swift_project_id --os-project-name $swift_project_name --os-user-domain-name $swift_user_domain_name --os-identity-api-version 3 download $container_name $file
done
