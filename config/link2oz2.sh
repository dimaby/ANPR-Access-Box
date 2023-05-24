#!/bin/bash

res=$(curl --location --request GET 'https://api.ngrok.com/tunnels' \
--header 'Authorization: Bearer 2IP35mlS0yc7tslLEAHbYqcTkbg_6vRdBB6KoKh9VMJwKz79f' \
--header 'Ngrok-Version: 2' | awk 'BEGIN { FS="\""; RS="," }; { if ($2 == "public_url") {print $4}}')

if [ -z "$res" ]  
then
    echo "No tunnels"
    exit
fi

ip_port=$(echo ${res:6})

arr=($(echo $ip_port | tr ":" "\n"))

ip=$(echo ${arr[0]})
port=$(echo ${arr[1]})

#ssh root@$ip -p $port
sudo ssh -L 80:127.0.0.1:80 -L 81:127.0.0.1:81 -L 82:127.0.0.1:82 root@$ip -p $port
