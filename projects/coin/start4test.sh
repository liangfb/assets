#!/bin/bash
echo "bucket:"$1 >> $instanceid.log
sudo yum update -y
#sudo yum install python3 git -y
#git clone https://github.com/Chia-Network/chia-blockchain.git -b latest
#cd chia-blockchain
#sh install.sh
#. ./activate
#chia init
instanceid=$(curl -s 169.254.169.254/1.0/meta-data/instance-id)
echo "plot" >> $instanceid.log
echo $(date) >> $instanceid.log
#chia plots create -k 32 -b 8000 -r 2 -u 128 -n 1 -t /mnt/hrssg/tmp -d /mnt/hrssg/chia -f 86e2861729d0c80cdbbf534b887a5f12cd71db41666f0be077743f8b06edd3f09acc8eacfbb20cd1977777a5ca7bd4c2 -p 9657d073106e7d07ffef12f1922f361a8c8bb52630e674363039ec8bf5fafa7d2580b8c3379e87548bcc1f88d28b9c27
echo "plot completed" >> $instanceid.log
echo $(ll /mnt/data/testdir/) >> $instanceid.log
echo "copy" >> $instanceid.log

whilecondition=true
while [ $whilecondition=true ]
do
    aws s3 sync --storage-class ONEZONE_IA /mnt/data/testdir/ s3://$1
    if [ "$?" -eq 0 ]
    then
        filename=$(ls /mnt/data/testdir/*.plot)
        totalFoundObject=$(aws s3 ls s3://${1}/${filename} --recursive --summarize | grep "Total Objects: " | sed 's/[^0-9]*//g')
        if [ $totalFoundObject -ge 1 ]
        then
            echo "copy completed" >> $instanceid.log
            aws s3 cp $instanceid.log s3://chiaplotlogs
            sudo shutdown now
        else
            echo "sleep and retry" >> $instanceid.log
            sleep 5m
        fi
    else
        sleep 5m
        echo "sleep and retry" >> $instanceid.log
    fi 
done
