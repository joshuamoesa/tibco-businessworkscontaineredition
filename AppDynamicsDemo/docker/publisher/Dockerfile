FROM tibco/bwce:base
LABEL author=joshua
ADD Publisher.application_1.0.0.ear /

EXPOSE 8081 7777 8090 5005 8080 80

ENV FTL_ENDPOINT="EP_ESB_PNP_Listen"
ENV FTL_REALM_SERVER_URL="http://host.docker.internal:8080"
ENV FTL_APPLICATION_NAME="PNP"

# AppDynamics Specific Configuration
#------------------------------------
ENV BW_JAVA_OPTS="-javaagent:/tmp/agent/javaagent.jar -Dappdynamics.controller.hostName=postnldev.saas.appdynamics.com -Dappdynamics.controller.port=443 -Dappdynamics.agent.applicationName=ESB_TST -Dappdynamics.agent.tierName=Publisher -Dappdynamics.agent.nodeName=localdevmachine_Publisher -Dappdynamics.agent.accountName=postnldev -Dappdynamics.agent.accountAccessKey=5102a2a5-ad04-4f1a-808b-815d82a5c3ed -Dappdynamics.controller.ssl.enabled=true"

USER root
RUN chmod 755 /tmp

#COPY custom-activity-correlation.xml /tmp/agent/ver20.8.0.30686/conf
#ENV BW_JAVA_OPTS="-javaagent:/tmp/agent/javaagent.jar -Dappdynamics.agent.tierName=ADMonitorAgentDemo -Dappdynamics.agent.nodeName=localdevmachine_ADMonitorAgentDemo"
#-Dappdynamics.agent.reuse.nodeName=true -Dappdynamics.agent.reuse.nodeName.prefix=bwce -Dsun.net.inetadditt1=300