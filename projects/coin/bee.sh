#!/bin/bash
if [ $# -lt 1 ]; then 
    echo "Please specify parameter. Format: ./start.sh <swap endpoint> <isfullnode>."
    echo "Exit with error."
    exit 1
fi
isfullnode=${2:-'false'}
sudo su
yum install  jq -y
wget https://github.com/ethersphere/bee-clef/releases/download/v0.4.12/bee-clef_0.4.12_amd64.rpm
wget https://github.com/ethersphere/bee/releases/download/v0.6.1/bee_0.6.1_amd64.rpm
rpm -i bee-clef_0.4.12_amd64.rpm
rpm -i bee_0.6.1_amd64.rpm
echo "swap-endpoint: $1" >> /etc/bee/bee.yaml
echo "full-node: $isfullnode" >> /etc/bee/bee.yaml
echo "cors-allowed-origins: \"*\"" >> /etc/bee/bee.yaml
echo "welcome-message: \"Hello world! \"" >> /etc/bee/bee.yaml
systemctl start bee
region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r)
aws dynamodb describe-table --table-name swarmaddr
if [ "$?" -neq 0 ]
then
    aws dynamodb create-table --table-name swarmaddr --attribute-definitions AttributeName=addr,AttributeType=S --key-schema AttributeName=addr,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
fi
addr='0x'$(bee-get-addr | awk 'NR==2' | cut -d ":" -f 2 | cut -d "." -f 1 | xargs)
keyfile=$(bee-clef-keys | awk 'NR==1' | sed 's/Key exported to //')
passfile=$(bee-clef-keys | awk 'NR==2' | sed 's/Pass exported to //')
key=$(cat $keyfile)
escapedkey=$(echo $key | sed 's/\"/\\\"/g')
pass=$(cat $passfile)
aws dynamodb put-item --table-name swarmaddr --item "{\"addr\": {\"S\": \"$addr\"}, \"privatekey\": {\"S\": \"$escapedkey\"}, \"password\": {\"S\": \"$pass\"}}" --region us-west-2
