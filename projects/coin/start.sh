#!/bin/bash
if [ $# -lt 1 ]; then 
    echo "Please specify S3 bucket and loca data directory. Format: ./start.sh <bucket> <local data directory>."
    echo "Exit with error."
    exit 1
fi
destdir=${2:-'/mnt/tmp/data'}
echo $1 >> $instanceid.log
echo $destdir >> $instanceid.log
sudo yum update -y
sudo yum install python3 git -y
git clone https://github.com/Chia-Network/chia-blockchain.git -b latest
cd chia-blockchain
sh install.sh
. ./activate
chia init
instanceid=$(curl -s 169.254.169.254/1.0/meta-data/instance-id)
echo "Plot started" >> $instanceid.log
echo $(date) >> $instanceid.log
chia plots create -k 32 -r 2 -n 1 -t /mnt/tmp -d $destdir
echo "Plot completed" >> $instanceid.log
echo $(date) >> $instanceid.log
echo $(ll $destdir) >> $instanceid.log
echo "Copy started" >> $instanceid.log
whilecondition=true
while [ $whilecondition=true ]
do
    aws s3 sync --storage-class ONEZONE_IA $destdir s3://$1
    if [ "$?" -eq 0 ]
    then
        filename=$(basename $(ls $destdir/*.plot))
        echo $filename >> $instanceid.log
        totalFoundObject=$(aws s3 ls s3://${1}/${filename} --recursive --summarize | grep "Total Objects: " | sed 's/[^0-9]*//g')
        echo $totalFoundObject >> $instanceid.log
        if [ $totalFoundObject -ge 1 ]
        then
            echo "Copy completed" >> $instanceid.log
            aws s3 cp $instanceid.log s3://chiaplotlogs
            sudo shutdown now
        else
            echo "Sleep and retry" >> $instanceid.log
            sleep 5m
        fi
    else
        sleep 5m
        echo "Sleep and retry" >> $instanceid.log
    fi 
done
