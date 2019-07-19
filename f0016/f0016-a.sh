#!/usr/bin/env bash

latest_year=$1
latest_week=$2
db_name=$3
new_db_name=$4
prefix=$5
py_name=$6
folder=$7

for file in $folder/"$prefix"*.gz; do
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  year=${filename:0:4}
  left=${filename#*_W}
  week=${left%_T*}
  if [ $year -eq $latest_year ]; then
    if [ $week -gt $latest_week ]; then
      mongorestore --gzip --archive=$file --nsFrom "${db_name}.*" --nsTo "${new_db_name}.*" \
      && python3 $py_name $filename $new_db_name \
      && echo $filename > geoname_latest_collection.txt \
      && mongo $new_db_name --eval "db.getCollection('$filename').drop()"
    fi
  else
    if [ $year -gt $latest_year ]; then
      mongorestore --gzip --archive=$file --nsFrom "${db_name}.*" --nsTo "${new_db_name}.*" \
      && python3 $py_name $filename $new_db_name \
      && echo $filename > geoname_latest_collection.txt \
      && mongo $new_db_name --eval "db.getCollection('$filename').drop()"
    fi
  fi
done
