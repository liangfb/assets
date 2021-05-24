#!/bin/bash
sudo su
echo $1 >> $instanceid.log
echo $2 >> $instanceid.log
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
chia plots create -k 32 -r 2 -n 1 -t /mnt/tmp -d $2
echo "Plot completed" >> $instanceid.log
echo $(date) >> $instanceid.log
echo $(ll $2) >> $instanceid.log
echo "Copy started" >> $instanceid.log
whilecondition=true
while [ $whilecondition=true ]
do
    aws s3 sync --storage-class ONEZONE_IA $2 s3://$1
    if [ "$?" -eq 0 ]
    then
        filename=$(basename $(ls $2/*.plot))
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
