#!/usr/bin/env bash

folder=$1
db_name=$2
output_file=$3

for file in $folder/*Australia*.gz; do
  echo "$file"
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  subfilename="${filename#*mongodb_}"
  mongorestore --gzip --archive=$filename \
  && count=`mongo $db_name --eval "printjson(db.$subfilename.count());" --quiet` \
  && index=`mongo $db_name --eval "printjson(db.$subfilename.getIndexes());" --quiet` \
  && echo "$filename, $count,$index" >> $output_file \
  && mongo $db_name --eval "db.$subfilename.drop()"

  #echo $ind | tr ' ' ','
  #echo ${ind// /,}
done
