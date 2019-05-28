#!/usr/bin/env bash

# get ip and port from ini file
IP=$(awk -F "=" '/IP/ {print $2}' config.ini)
Port=$(awk -F "=" '/MongoDB-Port/ {print $2}' config.ini)
DB=$(awk -F "=" '/DB-Name/ {print $2}' config.ini)
Drop=$(awk -F "=" '/Drop-Collection/ {print $2}' config.ini)
Str=$(awk -F "=" '/Start_Str/ {print $2}' config.ini)

# get all collections name
collections=$(mongo $IP:$(($Port))/$DB --quiet --eval "db.getCollectionNames().join(',')" | sed 's/,/ /g')

# get current timestamp
currenttimestamp=$(date +%s000)

# get current year
currentyear=$(date +'%Y')
echo "current year: "$currentyear

# get current week
currentweek=$(((((($currenttimestamp-1546214400000))/604800000))+1))
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
    mongodump --archive=mongodb_$i.gz --gzip --host $IP --port $Port --db $DB -c $i && mongo $IP:$(($Port))/$DB --eval "db['$i'].drop()" && echo "collection '$i' done: already dumped and droped from database"
  else
    mongodump --archive=mongodb_$i.gz --gzip --host $IP --port $Port --db $DB -c $i && echo "collection '$i' done: already dumped from database"
  fi
done
