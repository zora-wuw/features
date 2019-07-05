#!/usr/bin/env bash

folder=$1
db_name=$2
output_file=$3

for file in $folder/*Australia*.gz; do
  filename=$(basename -- "$file")
  filename1="${filename%.*}"
  subfilename="${filename1#*mongodb_}"
  mongorestore --gzip --archive=$file \
  && count=`mongo $db_name --eval "printjson(db.$subfilename.count());" --quiet` \
  && index=`mongo $db_name --eval "printjson(db.$subfilename.getIndexes());" --quiet` \
  && echo "$filename, $count,$index" >> $output_file \
  && mongo $db_name --eval "db.$subfilename.drop()"

  #echo $ind | tr ' ' ','
  #echo ${ind// /,}
done
