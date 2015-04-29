#! /bin/bash

if [ "$#" -ne 2 ]; then
  echo "Enter the start and finish index"
  exit 1
fi

##Using the config file
filename='./data/wet.paths'
n=0
while read p; do

  if [ $n -ge $1 ]; then
    echo "Copying file $n from s3 <----"
    wget https://aws-publicdatasets.s3.amazonaws.com/$p 

    echo "Changing file name"
    printf -v j "%04d" $n
    echo "New file: CC-MAIN-20150124161055-0$j-ip-10-180-212-252.ec2.internal.warc.wet.gz"
    mv *.wet.gz CC-MAIN-20150124161055-0$j-ip-10-180-212-252.ec2.internal.warc.wet.gz

    echo "Pushing to HDFS"
    hdfs dfs -copyFromLocal *.wet.gz /data/

    echo "Deleting wet file"
    rm ./*.wet.gz
  fi

  #Ensure we don't pull more than we request.
  n=$(( n+1 ))
  if [ $n -ge $2 ]; then
    echo "Finished transferring files."
    exit 1
  fi 
done < $filename