#!/usr/bin/env bash

db_name=$1
new_db_name=$2
py_name=$3
folder=$4

for file in $folder/*Australia*.gz; do
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  year=${filename:0:4}
  left=${filename#*_W}
  week=${left%_T*}
  if [ "$year" -eq "2018" ]; then
    if [ "$week" -gt "51" ]; then
      mongorestore --gzip --archive=$file --nsFrom "${db_name}.*" --nsTo "${new_db_name}.*" \
      && python3 $py_name $filename $new_db_name \
      && echo $filename > geoname_latest_collection.txt \
      && mongo $new_db_name --eval "db.getCollection('$filename').drop()"
    fi
  else
    if [ "$year" -gt "2018" ]; then
      mongorestore --gzip --archive=$file --nsFrom "${db_name}.*" --nsTo "${new_db_name}.*" \
      && python3 $py_name $filename $new_db_name \
      && echo $filename > geoname_latest_collection.txt \
      && mongo $new_db_name --eval "db.getCollection('$filename').drop()"
    fi
  fi
done
