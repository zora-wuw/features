#!/usr/bin/env bash

folder=$1
db_name=$2
py_name=$3
prefix=$4
latest_year=$5
latest_week=$6
new_db_name=$7

for file in $folder/"$prefix"*.gz; do
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  year="${filename:0:4}"
  left="${filename#*_W}"
  week="${left%_T*}"
  echo $year
  echo $week
  mongorestore --gzip --archive=$file --nsFrom "${db_name}.*" --nsTo "${new_db_name}.*" \
  && python3 $py_name $filename $new_db_name \
  && echo $filename > geoname_latest_collection.txt \
  && mongo $new_db_name --eval "db.getCollection('$filename').drop()"
done
