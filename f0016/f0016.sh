#!/usr/bin/env bash

folder=$1
db_name=$2

for file in $folder/mongodb_*.gz; do
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  mongorestore --gzip --archive=$file \
  && python3 f0016.py $filename \
  && mongo $db_name --eval "db.$filename.drop()"
done
