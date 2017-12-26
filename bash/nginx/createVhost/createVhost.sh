#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ "$1" != "" ]; then
    echo "Creating api space for $1"
    apiname=$1
else
    echo "Please input the API name"
    read apiname
    echo "Creating API space for $apiname"
fi

echo "checking string"

if [[ $apiname =~ ^[A-Za-z0]+$ ]]; then
        echo "API name must be lowercase, converting to $apiname to lowercase."
        apiname="$(echo $apiname | tr '[:upper:]' '[:lower:]')"
else
        echo "$apiname contains invalid characters. exiting"
        exit
fi

mkdir "/var/www/api/$apiname"
cp /etc/nginx/sites-available/template /etc/nginx/sites-available/$apiname
sed -i "s/<APINAME>/$apiname/g" /etc/nginx/sites-available/$apiname
ln -s /etc/nginx/sites-available/$apiname /etc/nginx/sites-enabled/$apiname
nginx -t -q
if [ $? -ne 0 ]; then
        echo "an error occured please check the config"
        rm /etc/nginx/sites-enabled/$apiname
else
        echo "reloading the server. stand by"
        nginx -s reload
fi


