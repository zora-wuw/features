#!/usr/bin/env bash

config_file=$1
container_name=$2
file_array=$3
action=$4

swift_username=$(awk -F "=" '/Username/ {print $2}' $config_file)
swift_pwd=$(awk -F "=" '/Psword/ {print $2}' $config_file)
swift_project_id=$(awk -F "=" '/OS-Project-ID/ {print $2}' $config_file)
swift_project_name=$(awk -F "=" '/OS-Project-Name/ {print $2}' $config_file)
swift_region_name=$(awk -F "=" '/OS-Region-Name/ {print $2}' $config_file)
swift_user_domain_name=$(awk -F "=" '/OS-User-Domain-Name/ {print $2}' $config_file)
swift_auth_url=$(awk -F "=" '/OS-Auth-URL/ {print $2}' $config_file)
swift_auth_url=$(awk -F "=" '/OS-Auth-URL/ {print $2}' $config_file)
swift_temp_url_key=$(awk -F "=" '/Temp-URL-Key/ {print $2}' $config_file)
swift_object_url=$(awk -F "=" '/Object-URL/ {print $2}' $config_file)


if [ "$action" == "download" ]; then
  for file in $file_array; do
    swift --os-username $swift_username --os-password $swift_pwd --os-auth-url $swift_auth_url --os-region-name $swift_region_name --os-project-id $swift_project_id --os-project-name $swift_project_name --os-user-domain-name $swift_user_domain_name --os-identity-api-version 3 download $container_name $file
  done
elif [ "$action" == "download_prefix" ]; then
  for file in $file_array; do
    swift --os-username $swift_username --os-password $swift_pwd --os-auth-url $swift_auth_url --os-region-name $swift_region_name --os-project-id $swift_project_id --os-project-name $swift_project_name --os-user-domain-name $swift_user_domain_name --os-identity-api-version 3 download --prefix $file $container_name
  done
elif [ "$action" == "upload" ]; then
  for file in $file_array; do
    swift --os-username $swift_username --os-password $swift_pwd --os-auth-url $swift_auth_url --os-region-name $swift_region_name --os-project-id $swift_project_id --os-project-name $swift_project_name --os-user-domain-name $swift_user_domain_name --os-identity-api-version 3 upload $container_name $file
  done
elif [ "$action" == "tempurl" ]; then
  expire_seconds=$5
  swift tempurl GET $expire_seconds ${swift_object_url}${container_name}/${file_array} $swift_temp_url_key --os-username $swift_username --os-password $swift_pwd --os-auth-url $swift_auth_url --os-region-name $swift_region_name --os-project-id $swift_project_id --os-project-name $swift_project_name --os-user-domain-name $swift_user_domain_name --os-identity-api-version 3
fi
