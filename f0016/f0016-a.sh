#!/bin/bash

# declare port is an integer
declare -i port

folder=$1
prefix=$2
ip=$3
port=$4
db_name=$5
new_db_name=$6
py_name=$7
latest_year=$8
latest_week=$9

for file in $folder/"$prefix"*.gz; do
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  year=${filename:0:4}
  left=${filename#*_W}
  week=${left%_T*}
  if [ "$year" -eq "$latest_year" ]; then
    if [ "$week" -gt "$latest_week" ]; then
      mongorestore --host $ip --port $port --gzip --archive=$file --nsFrom "${db_name}.*" --nsTo "${new_db_name}.*" \
      && python3 $py_name $filename $new_db_name \
      && echo $filename > geoname_latest_collection.txt \
      && mongo --host $ip --port $port $new_db_name --eval "db.getCollection('$filename').drop()"
    fi
  else
    if [ "$year" -gt "$latest_year" ]; then
      mongorestore --host $ip --port $port --gzip --archive=$file --nsFrom "${db_name}.*" --nsTo "${new_db_name}.*" \
      && python3 $py_name $filename $new_db_name \
      && echo $filename > geoname_latest_collection.txt \
      && mongo --host $ip --port $port $new_db_name --eval "db.getCollection('$filename').drop()"
    fi
  fi
done
