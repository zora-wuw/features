#!/bin/bash

folder=$1
prefix=$2
db_name=$3
new_db_name=$4
py_name=$5
latest_year=$6
latest_week=$7

for file in $folder/"$prefix"*.gz; do
  echo $file
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
