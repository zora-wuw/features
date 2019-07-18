#!/usr/bin/env bash

folder=$1
db_name=$2
py_name=$3
prefix=$4
latest_year=$5
latest_week=$6

for file in $folder/"$prefix"*.gz; do
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  year=${filename:0:4}
  left=${filename#*_W}
  week=${left%_T*}
  if ! [[ $year -lt $latest_year ]]; then
    if [[ $week -gt $latest_week ]]; then
      mongorestore --gzip --archive=$file
      && python3 $py_name $filename \
      && mongo $db_name --eval "db.getCollection('$filename').drop()"
    fi
  fi
done
