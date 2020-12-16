FROM tibco/bwce:base
LABEL author=joshua
ADD Subscriber.application_1.0.0.ear /
#EXPOSE 8081 7777 8090 5005 8080 80

ENV FTL_ENDPOINT="EP_ESB_PNP_Connect"
ENV FTL_REALM_SERVER_URL="http://host.docker.internal:8080"
ENV FTL_APPLICATION_NAME="PNP"

# AppDynamics Specific Configuration
#-----------------------------------

ENV BW_JAVA_OPTS="-javaagent:/tmp/agent/javaagent.jar -Dappdynamics.controller.hostName=postnldev.saas.appdynamics.com -Dappdynamics.controller.port=443 -Dappdynamics.agent.applicationName=ESB_TST -Dappdynamics.agent.tierName=Subscriber -Dappdynamics.agent.nodeName=localdevmachine_Subscriber -Dappdynamics.agent.accountName=postnldev -Dappdynamics.agent.accountAccessKey=5102a2a5-ad04-4f1a-808b-815d82a5c3ed -Dappdynamics.controller.ssl.enabled=true"

USER root
RUN chmod 755 /tmp