#!/bin/bash
#Get a list of buckets
bucket_list=`aws s3api list-buckets  | jq .Buckets[].Name --raw-output`
echo "The following buckets are not using default encryption:"
#Loop through buckets
for bucket in $bucket_list
do
        #Get encryption on the bucket
        result=`aws s3api get-bucket-encryption --bucket $bucket 2>&1`
        #Did we get an error?
        if [ $? -ne 0 ]
        then
           #print the bucket name because there's no encryption on it
           echo $bucket
fi
done
