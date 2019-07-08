#!/usr/bin/env bash

folder=$1
db_name=$2
py_name=$3

for file in $folder/mongodb_2019_W14_Twitter_Australia*.gz; do
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  filename="${filename#*mongo_}"
  mongorestore --gzip --archive=$file \
  && python3 $py_name $filename $db_name\
  && mongo $db_name --eval "db.$filename.drop()"
done
