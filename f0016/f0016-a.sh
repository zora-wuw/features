#!/usr/bin/env bash

latest_year=$(awk -F "=" '/Latest-Year/ {print $2}' config.ini)
latest_week=$(awk -F "=" '/Latest_Week/ {print $2}' config.ini)
db_name=$(awk -F "=" '/DB-Name/ {print $2}' config.ini)
new_db_name=$(awk -F "=" '/New-DB-Name/ {print $2}' config.ini)
prefix=$(awk -F "=" '/Prefix/ {print $2}' config.ini)
py_name=$(awk -F "=" '/Py-Name/ {print $2}' config.ini)
folder=$(awk -F "=" '/Folder/ {print $2}' config.ini)

for file in $folder/"$prefix"*.gz; do
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  year=${filename:0:4}
  left=${filename#*_W}
  week=${left%_T*}
  if [ "$year" -eq "$latest_year" ]; then
    if [ "$week" -gt "$latest_week" ]; then
      mongorestore --gzip --archive=$file --nsFrom "${db_name}.*" --nsTo "${new_db_name}.*" \
      && python3 $py_name $filename $new_db_name \
      && echo $filename > geoname_latest_collection.txt \
      && mongo $new_db_name --eval "db.getCollection('$filename').drop()"
    fi
  else
    if [ "$year" -gt "$latest_year" ]; then
      mongorestore --gzip --archive=$file --nsFrom "${db_name}.*" --nsTo "${new_db_name}.*" \
      && python3 $py_name $filename $new_db_name \
      && echo $filename > geoname_latest_collection.txt \
      && mongo $new_db_name --eval "db.getCollection('$filename').drop()"
    fi
  fi
done
