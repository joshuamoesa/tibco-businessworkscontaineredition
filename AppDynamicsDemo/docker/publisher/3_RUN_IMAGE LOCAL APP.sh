#!/bin/sh 

docker run -p 8081:8081 -p 5005:5005 -p 8090:8090 -e BW_LOGLEVEL="DEBUG" -i tibco/bwce:ADDemo_Publisher

#docker run -v /tmp/custom-activity-correlation.xml:/tmp/agent/ver20.8.0.30686/conf/custom-activity-correlation.xml -p 8081:8081 -p 5005:5005 -p 8090:8090 -e BW_LOGLEVEL="DEBUG" -i tibco/bwce:ADMonitorAgentDemoProd
