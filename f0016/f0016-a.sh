#!/usr/bin/env bash

folder=$1

for file in $folder/*.gz; do
  echo $file
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  year=${filename:0:4}
  left=${filename#*_W}
  week=${left%_T*}
  echo $year
  echo $week
  # if [ "$year" -eq "2018" ]; then
  #   if [ "$week" -gt "51" ]; then
  #     mongorestore --gzip --archive=$file --nsFrom "${db_name}.*" --nsTo "${new_db_name}.*" \
  #     && python3 $py_name $filename $new_db_name \
  #     && echo $filename > geoname_latest_collection.txt \
  #     && mongo $new_db_name --eval "db.getCollection('$filename').drop()"
  #   fi
  # else
  #   if [ "$year" -gt "2018" ]; then
  #     mongorestore --gzip --archive=$file --nsFrom "${db_name}.*" --nsTo "${new_db_name}.*" \
  #     && python3 $py_name $filename $new_db_name \
  #     && echo $filename > geoname_latest_collection.txt \
  #     && mongo $new_db_name --eval "db.getCollection('$filename').drop()"
  #   fi
  # fi
done
