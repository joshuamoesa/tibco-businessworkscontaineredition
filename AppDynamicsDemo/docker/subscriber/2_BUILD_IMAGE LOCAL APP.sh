#!/bin/sh 
docker build --build-arg AD_APPLICATION_NAME=$1 --build-arg AD_ACCOUNT_NAME=$2 --build-arg AD_ACCOUNT_ACCESSKEY=$3 -t tibco/bwce:ADDemo_Subscriber .