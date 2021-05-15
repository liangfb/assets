#!/bin/bash
cd /home/ec2-user/chia-blockchain/
. ./activate
chia start farmer
instanceid=$(curl -s 169.254.169.254/1.0/meta-data/instance-id)
echo "plot" >> $instanceid.log
echo $(date) >> $instanceid.log
chia plots create -k 32 -r 2 -n 1 -t /mnt/tmp -d /chia
echo "plot completed" >> $instanceid.log
echo $(ll /chia/) >> $instanceid.log
echo "copy" >> $instanceid.log
aws s3 cp /chia/* s3://chplotdata
echo "copy completed" >> $instanceid.log
aws s3 cp $instanceid.log s3://chiaplotlogs
shutdown now
