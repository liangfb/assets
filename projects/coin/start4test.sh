#!/bin/bash
sudo su
echo $1 >> $instanceid.log
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
echo "plot completed" >> $instanceid.log
echo $(ll /mnt/data/testdir/) >> $instanceid.log
echo "copy" >> $instanceid.log
echo "testcontent" >> /mnt/data/testdir/asdfghjhkjl.plot
whilecondition=true
while [ $whilecondition=true ]
do
    aws s3 sync --storage-class ONEZONE_IA /mnt/data/testdir/ s3://$1
    if [ "$?" -eq 0 ]
    then
        echo "inif" >> $instanceid.log
        filename=$(ls /mnt/data/testdir/*.plot)
        echo $filename >> $instanceid.log
        totalFoundObject=$(aws s3 ls s3://${1}/${filename} --recursive --summarize | grep "Total Objects: " | sed 's/[^0-9]*//g')
        echo $totalFoundObject >> $instanceid.log
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
