aws s3 sync s3://$1 .

FILES=./*.gz
for f in $FILES
do
 	echo "Processing $f file..."
	mongorestore --gzip --archive=$f  -v
done