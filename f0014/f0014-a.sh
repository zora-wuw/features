#!/usr/bin/env bash

folder=$1
db_name=$2
output_file=$3

for file in $folder/*2019_W14_Twitter_Australia*.gz; do
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  filename="${filename#*mongodb_}"
  mongorestore --gzip --archive=$file \
  && count=`mongo $db_name --eval "printjson(db.$filename.count());" --quiet` \
  && index=`mongo $db_name --eval "printjson(db.$filename.getIndexes());" --quiet` \
  && echo "$filename, $count,$index" >> $output_file \
  && mongo $db_name --eval "db.$filename.drop()"

  #echo $ind | tr ' ' ','
  #echo ${ind// /,}
done
