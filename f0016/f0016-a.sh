#!/usr/bin/env bash

folder=$1
db_name=$2
py_name=$3
prefix=$4

for file in $folder/"$prefix"*.gz; do
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  filename="${filename#*mongodb_}"
  mongorestore --gzip --archive=$file \
  && python3 $py_name $filename \
  && echo $filename > geoname_latest_collection.txt \
  && mongo $db_name --eval "db.getCollection('$filename').drop()"
done
