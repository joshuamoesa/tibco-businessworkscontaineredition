# AppDynamicsDemo

This README.md contains additional notes that complement the AppDynamics article 'Howto instrument and correlate TIBCO FTL exit calls in TIBCO'[1]. Main difference with [1] is that I'm using a predefined FTL message format instead.

The BWCE code:

<img src="https://github.com/joshuamoesa/tibco-businessworkscontaineredition/blob/master/AppDynamicsDemo/resources/images/screenshot_tibcobusinessstudio_bwcecode.png" width="500">

The end result in AppDynamics:

<img src="https://github.com/joshuamoesa/tibco-businessworkscontaineredition/blob/master/AppDynamicsDemo/resources/images/screenshot_appdynamics_endresult.png" width="500">

## Prerequisites (macOS)

- Docker Desktop Community 2.4.0 [Docker](https://www.docker.com/products/docker-desktop)
- TIBCO FTL Enterprise (version 5.4 as of writing) [TIBCO download](https://download.tibco.com)
- TIBCO BWCE (version 2.5.4 as of writing) [TIBCO download](https://download.tibco.com)
- AppDynamics javaagent (AppServerAgent-1.8-21.4.0.32403.zip as of writing) [AppDynamics download](https://download.appdynamics.com/download/#version=&apm=jvm%2Cjava-agent-api%2Copentracer%2Cjava-jdk8&os=linux%2Cosx%2Cwindows&platform_admin_os=linux%2Cosx%2Cwindows&appdynamics_cluster_os=linux&events=linuxwindows&eum=linux%2Cwindows%2Cgeoserver%2Cgeodata%2Csynthetic%2Csynthetic-server&page=1&apm_os=windows%2Clinux%2Calpine-linux%2Cosx%2Csolaris%2Csolaris-sparc%2Caix)

## Create the TIBCO BWCE base image

Prepare your local environment in order to create a working Docker base image.

### Install TIBCO BWCE software

Download and install TIBCO BWCE software on your local machine. Then, download the runtime software and copy bwce-runtime-2.5.4.zip to
[tibco root path]/tibco/bwce/bwce/2.5/docker/resources/bwce-runtime/

### Install TIBCO FTL software

Make sure FTL software is included in the correct TIBCO installation folders on your local machine

This is where I put my stuff:

- FTL JAR-files folder (no ZIP but folder /com.tibco.ftl_5.4.0.009) in
/Users/joshuamoesa/Applications/tibco/bwce/bwce/2.5/docker/resources/addons/jars
- ftl_linux_client_libs.zip in /Users/joshuamoesa/Applications/tibco/bwce/bwce/2.5/docker/resources/addons/lib
- TIB_bwpluginftl_6.4.4_v6_bwce-runtime.zip in /Users/joshuamoesa/Applications/tibco/bwce/bwce/2.5/docker/resources/addons/plugins

### Install & configure AppDynamics javaagent

#### AppServerAgent ZIP

Copy downloaded AppServerAgent-1.8-20.8.0.30686.zip to [tibco root path]/tibco/bwce/bwce/2.5/docker/resources/addons/monitor-agents

#### Replace default custom-activity-correlation.xml config

Replace default custom-activity-correlation.xml with the proposed version (*Step 1 - custom-activity-correlation.xml (only send-receive scenario).txt* in [1]) in AppServerAgent-1.8-21.4.0.32403.zip

```sh
#Get path of custom-activity-correlation.xml in ZIP-file
zipinfo AppServerAgent-1.8-21.4.0.32403.zip

#Delete default custom-activity-correlation.xml from ZIP-file
zip -d AppServerAgent-1.8-21.4.0.32403.zip ver21.4.0.32403/conf/custom-activity-correlation.xml
   
#Add the new custom-activity-correlation.xml. Make sure you have the same root path on your local machine
#Example /ver21.4.0.32403/conf/custom-activity-correlation.xml
zip AppServerAgent-1.8-21.4.0.32403.zip ver21.4.0.32403/conf/custom-activity-correlation.xml
```

#### Replace default app-agent-config.xml config

Extract an app-agent-config.xml file and add the following include to the JAVA_AGENT_HOME/verx.x.x.x/conf/app-agent-config.xml in the fork-config section for all your FTL nodes.

`<include filter-type="EQUALS" filter-value="org.glassfish.jersey.server.ServerRuntime$AsyncResponder$2"/>`

Replace default app-agent-config.xml with your modified version in AppServerAgent-1.8-20.8.0.30686.zip

```sh
#Get path of app-agent-config.xml in ZIP-file
zipinfo AppServerAgent-1.8-21.4.0.32403.zip

#Delete dapp-agent-config.xml from ZIP-file
zip -d AppServerAgent-1.8-21.4.0.32403.zip ver21.4.0.32403/conf/app-agent-config.xml

#Add the modified app-agent-config.xml. Make sure you have the same root path on your local machine
#Example /ver20.8.0.30686/conf/custom-activity-correlation.xml
zip AppServerAgent-1.8-21.4.0.32403.zip ver21.4.0.32403/conf/app-agent-config.xml
```

#### (optional) Modify controller-info.xml environment config

If you choose to use the controller-info.xml file (instead of commandline properties or a property file), populate this file with the proper settings.
These are the fields you would typically set:

    <controller-host>environmentname.saas.appdynamics.com</controller-host>
    <controller-port>443</controller-port>
    <controller-ssl-enabled>true</controller-ssl-enabled>
    <use-simple-hostname>false</use-simple-hostname>
    <application-name>APPDYNAMICS_APPLICATION_NAME</application-name>
    <tier-name>ADMonitorAgentDemo</tier-name>
    <node-name>nodename_ADMonitorAgentDemo</node-name>
    <account-access-key>APPLICATION_ACCOUNT_ACCESS_KEY</account-access-key>

Some helpful commands:

```sh
zip -d AppServerAgent-1.8-21.4.0.32403.zip ver21.4.0.32403/conf/controller-info.xml
   
zip AppServerAgent-1.8-21.4.0.32403.zip ver21.4.0.32403/conf/controller-info.xml
```

### Create TIBCO BWCE base image

- In Dockerfile, set the necessary BW_JAVA_OPTS variable arguments:

```
ENV BW_JAVA_OPTS="-javaagent:/tmp/agent/javaagent.jar -Dappdynamics.controller.hostName=postnldev.saas.appdynamics.com -Dappdynamics.controller.port=443 -Dappdynamics.agent.applicationName=${AD_APPLICATION_NAME} -Dappdynamics.agent.tierName=Publisher -Dappdynamics.agent.nodeName=localdevmachine_Publisher -Dappdynamics.agent.accountName=${AD_ACCOUNT_NAME} -Dappdynamics.agent.accountAccessKey=${AD_ACCOUNT_ACCESSKEY} -Dappdynamics.controller.ssl.enabled=true"
```
When you need to deal with auto-scaling scenario's and nodenames arent's static, instead of -Dappdynamics.agent.nodeName use the following arguments: 
```
-Dappdynamics.agent.reuse.nodeName=true
-Dappdynamics.agent.reuse.nodeName.prefix=[YOUR PREFIX HERE]
```

- Create the TIBCO BWCE base Docker images for the publisher and the subscriber.

Run bash-scripts containing the Docker commands on this location:

```/docker/<publisher or subscriber>/1_BUILD_IMAGE LOCAL Base.sh```

- Create the TIBCO application Docker images

Run bash-scripts containing the Docker commands on this location:

```/docker/<publisher or subscriber>/2_BUILD_IMAGE LOCAL APP.sh```

Mind you that above script is meant to be invoked by below script:
```
#!/bin/sh
export AD_APPLICATION_NAME=[APPDYNAMICS_APPLICATION_NAME]
export AD_ACCOUNT_NAME=[APPDYNAMICS_ACCOUNT_NAME]
export AD_ACCOUNT_ACCESSKEY=[APPLICATION_ACCOUNT_ACCESS_KEY]

. 2_BUILD_IMAGE\ LOCAL\ APP.sh ${AD_APPLICATION_NAME} ${AD_ACCOUNT_NAME} ${AD_ACCOUNT_ACCESSKEY}%
```

### Add singularityheader field to the FTL message format

To make it work, the singularityheader field needs to be added to the FTL message format. The AppDynamics article [2] describes the situation where selected format config option is 'custom' and a local FTLMessageSchema.xsd needs to be modified.

When format is 'Predefined' in BWCE code, add the header using the FTL UI:
<img src="https://github.com/joshuamoesa/tibco-businessworkscontaineredition/blob/master/AppDynamicsDemo/resources/images/screenshot_tibcoftl_messageformat.jpg" width="500">

### Test your work

#### Run FTL cluster

- Prepare a FTL cluster using configuration from /resources/FTL/realm.json. This configuration defines the necessary Application and Endpoints needed to run the containers.
- Start your cluster (realm & persistence servers).

```sh
#Realmserver
cd /opt/tibco/ftl/[YOUR VERSION]/bin
sudo ./tibrealmserver --http 0.0.0.0:8080
sudo ./tibstore -n S1 -d data_dir -rs http://localhost:8080
sudo ./tibstore -n S2 -d data_dir -rs http://localhost:8080
sudo ./tibstore -n S3 -d data_dir -rs http://localhost:8080
```

#### Run BWCE containers

Run bash-scripts containing the Docker commands on this location:

```/docker/<publisher or subscriber>/3_RUN_IMAGE LOCAL APP.sh```

#### Invoke BWCE containers

Run bash-script which will perform a Curl call:

```/docker/publisher/5_TEST APP.sh```

This will return:

```
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8081 (#0)
> GET /person?name=joshua HTTP/1.1
> Host: localhost:8081
> User-Agent: curl/7.64.1
> Accept: */*
>
< HTTP/1.1 200 OK
< Date: Wed, 05 May 2021 13:30:26 GMT
< Content-Type: text/plain;charset=utf-8
< Access-Control-Allow-Origin: *
< Access-Control-Allow-Methods: HEAD,POST,GET,OPTIONS,DELETE,PUT,PATCH
< Access-Control-Allow-Headers: Content-Type, api_key, Authorization
< Content-Length: 47
< Server: Jetty(9.4.18.v20190429)
<
* Connection #0 to host localhost left intact
Successfully published message 'joshua' to FTL.* Closing connection 0
```

## Configure AppDynamics UI

### Add custom rule to show Subscriber outgoing traffic 

AppDynamics not always shows all outgoing traffic. With 'Live Discovery' you can inspect the Agents live data and create a rule so that AD in the future will include that data in dashboards.

<img src="https://github.com/joshuamoesa/tibco-businessworkscontaineredition/blob/master/AppDynamicsDemo/resources/images/screenshot_appdynamics_rule_config.png" width="500">

Result:

<img src="https://github.com/joshuamoesa/tibco-businessworkscontaineredition/blob/master/AppDynamicsDemo/resources/images/screenshot_appdynamics_rule.png" width="500">


### Create AppDynamics Agent Properties

In AppDynamics UI go to Tiers & Nodes > Actions: Configure App Server Agent. Click on your node. Select Use *Custom Configuration*. Add a property by clicking the +-sign. Click on Save to commit the changes.

Use the following settings:
* Name: error-safety-rule-error-threshold
* Description: Make sure that the instrumentation is not neutralized during the first 15 minutes of the application startup when there is no singularityheader set in the FTL messages.
* Type: Integer
* Value: -1

## References
- [1] [AppDynamics - Howto instrument and correlate TIBCO FTL exit calls in TIBCO](https://community.appdynamics.com/t5/Knowledge-Base/How-do-I-instrument-and-correlate-TIBCO-FTL-exit-calls-in-TIBCO/ta-p/33621)
- [2] [AppDynamics - How to get visibility into TIBCO with APM](https://www.appdynamics.com/blog/product/how-to-get-visibility-into-tibco-with-apm/)
- [3] [AppDynamics - App Agent Node Properties](https://docs.appdynamics.com/display/PRO45/App+Agent+Node+Properties)
- [4] [TIBCO BWCE 2.5.1 docs](https://docs.tibco.com/products/tibco-businessworks-container-edition-2-5-1)
- [5] [MEditor.md Open source online Markdown editor.](https://pandao.github.io/editor.md/en.html)
- [6] [Docker - Networking features in Docker Desktop for Mac](https://docs.docker.com/docker-for-mac/networking/#known-limitations-use-cases-and-workarounds)
- [7] [TIBCO - Integrating with FTL](https://docs.tibco.com/pub/bwce/2.5.4/doc/html/GUID-BAC1EBEA-0E6E-4DF7-B9B3-944A473EF8A3.html)
