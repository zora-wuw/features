#!/usr/bin/env bash

# get ip and port from ini file
IP=$(awk -F "=" '/IP/ {print $2}' config.ini)
Port=$(awk -F "=" '/MongoDB-Port/ {print $2}' config.ini)
DB=$(awk -F "=" '/DB-Name/ {print $2}' config.ini)
Drop=$(awk -F "=" '/Drop-Collection/ {print $2}' config.ini)
Str=$(awk -F "=" '/Start-Str/ {print $2}' config.ini)

# get all collections name
collections=$(mongo $IP:$(($Port))/$DB --quiet --eval "db.getCollectionNames().join(',')" | sed 's/,/ /g')

# get current timestamp
currenttimestamp=$(date +%s000)

# get current year
currentyear=$(date +'%Y')
echo "current year: "$currentyear

# set reference timestamp for each year
declare -a year_timestamp
year_timestamp=( [2020]=1577624400000 [2021]=1609678800000 [2022]=1641128400000 [2023]=1672578000000 [2024]=1704027600000 [2025]=1735477200000 )

# get reference timestamp
ref_timestamp=${year_timestamp[$currentyear]}

if [[ $currenttimestamp -lt $ref_timestamp ]]; then
  ref_timestamp=${year_timestamp[$currentyear-1]}
else
  if [[ $currenttimestamp -ge ${year_timestamp[$currentyear+1]} ]]; then
    ref_timestamp=${year_timestamp[$((currentyear+1))]}
    currentyear=$((currentyear+1))
  fi
fi

# get current week
currentweek=$(((((($currenttimestamp-$ref_timestamp))/604800000))+1))
echo "current week: " $currentweek

array=()

# get all old collections based on year and week
for col in $collections; do
  if [[ $col == $Str ]]; then
    year=${col:0:4}
    left=${col#*_W}
    week=${left%_T*}
    if [[ $year -lt $currentyear ]]; then
      array+=($col)
    else
      if [[ $week -lt $currentweek ]]; then
        array+=($col)
      fi
    fi
  fi
done

# dump collection and drop it after
for i in ${array[@]}; do
  echo "ready to dump collection '$i'"
  if [ $Drop == "1" ]; then
    mongodump --archive=$i.gz --gzip --host $IP --port $Port --db $DB -c $i && mongo $IP:$(($Port))/$DB --eval "db['$i'].drop()" && echo "collection '$i' done: already dumped and droped from database"
  else
    mongodump --archive=$i.gz --gzip --host $IP --port $Port --db $DB -c $i && echo "collection '$i' done: already dumped from database"
  fi
done
