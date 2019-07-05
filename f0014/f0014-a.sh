#!/usr/bin/env bash

folder=$1
db_name=$2
output_file=$3

for file in $folder/*mongodb_2019_W14_Twitter_Australia*.gz; do
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  filename="${filename#*mongodb_}"
  mongorestore --gzip --archive=$file \
  && count=`mongo $db_name --eval "printjson(db.$filename.count());" --quiet` \
  && echo "$count" \
  && index=`mongo $db_name --eval "printjson(db.$filename.getIndexes());" --quiet` \
  && echo "$index" \
  && echo "$file, $count,$index" \
  && echo "$file, $count,$index" >> $output_file \
  && mongo $db_name --eval "db.$filename.drop()"

  #echo $ind | tr ' ' ','
  #echo ${ind// /,}
done
