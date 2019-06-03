#!/usr/bin/env bash

folder=$1
db_name=$2
output_file=$3

for file in $folder/*.gz; do
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  mongorestore --gzip --archive=$file \
  && let count=`mongo $db_name --eval "printjson(db.$filename.count());" --quiet` \
  && index=`mongo $db_name --eval "printjson(db.Twitter_2017.getIndexes());" --quiet` \
  && ind=$(echo $index | jq -r '.[].name') \
  && indexname=$(echo $ind | tr ' ' ';') \
  && echo "$filename, $count,$indexname" >> $output_file \
  && mongo $db_name --eval "db.$filename.drop()"

  #echo $ind | tr ' ' ','
  #echo ${ind// /,}
done
