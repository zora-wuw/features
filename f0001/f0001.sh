aws s3 sync s3://$1 .

FILES=./*
for f in $FILES
do
  echo "Processing $f file..."
  # take action on each file. $f store current file name

done