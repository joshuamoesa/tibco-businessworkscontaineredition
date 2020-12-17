# AppDynamicsDemo

This README.md contains additional notes that complement the AppDynamics article 'Howto instrument and correlate TIBCO FTL exit calls in TIBCO'[1].

<img src="https://github.com/joshuamoesa/tibco-businessworkscontaineredition/blob/master/AppDynamicsDemo/resources/images/screenshot_appdynamics_endresult.png" width="500">

## Prerequisites (macOS)

- Docker Desktop Community 2.4.0 [Docker](https://www.docker.com/products/docker-desktop)
- TIBCO FTL Enterprise 5.4 [TIBCO download](https://download.tibco.com)
- TIBCO BWCE 2.5.1 [TIBCO download](https://download.tibco.com)
- AppDynamics javaagent [AppDynamics download](https://download.appdynamics.com/download/#version=&apm=jvm%2Cjava-agent-api%2Copentracer%2Cjava-jdk8&os=linux%2Cosx%2Cwindows&platform_admin_os=linux%2Cosx%2Cwindows&appdynamics_cluster_os=linux&events=linuxwindows&eum=linux%2Cwindows%2Cgeoserver%2Cgeodata%2Csynthetic%2Csynthetic-server&page=1&apm_os=windows%2Clinux%2Calpine-linux%2Cosx%2Csolaris%2Csolaris-sparc%2Caix)

## Create the TIBCO BWCE base image

Prepare your local environment in order to create a working Docker base image.

### Install TIBCO BWCE software

Download and install TIBCO BWCE software on your local machine. Then, download the runtime software and copy bwce-runtime-2.5.1.zip to /Users/joshuamoesa/Applications/tibco/bwce/bwce/2.5/docker/resources/bwce-runtime/

### Install TIBCO FTL software

Make sure FTL software is included in the correct TIBCO installation folders on your local machine

This is where I put my stuff:

- FTL JAR-files folder (folder com.tibco.ftl_5.4.0.009) in
/Users/joshuamoesa/Applications/tibco/bwce/bwce/2.5/docker/resources/addons/jars
- ftl_linux_client_libs.zip in /Users/joshuamoesa/Applications/tibco/bwce/bwce/2.5/docker/resources/addons/lib
- TIB_bwpluginftl_6.4.4_v6_bwce-runtime.zip in /Users/joshuamoesa/Applications/tibco/bwce/bwce/2.5/docker/resources/addons/plugins

### Install & configure AppDynamics javaagent

#### AppServerAgent ZIP

AppServerAgent-1.8-20.8.0.30686.zip (use your own distribution) in /Users/joshuamoesa/Applications/tibco/bwce/bwce/2.5/docker/resources/addons/monitor-agents

#### Replace default custom-activity-correlation.xml config

Replace default custom-activity-correlation.xml with the proposed version (*Step 1 - custom-activity-correlation.xml (only send-receive scenario).txt* in [1]) in AppServerAgent-1.8-20.8.0.30686.zip

```sh
#Get path of custom-activity-correlation.xml in ZIP-file
zipinfo AppServerAgent-1.8-20.8.0.30686.zip

#Delete default custom-activity-correlation.xml from ZIP-file
zip -d AppServerAgent-1.8-20.8.0.30686.zip ver20.8.0.30686/conf/custom-activity-correlation.xml
   
#Add the new custom-activity-correlation.xml. Make sure you have the same root path on your local machine
#Example /ver20.8.0.30686/conf/custom-activity-correlation.xml
zip AppServerAgent-1.8-20.8.0.30686.zip ver20.8.0.30686/conf/custom-activity-correlation.xml
```

#### Replace default app-agent-config.xml config

Extract an app-agent-config.xml file and add the following include to the JAVA_AGENT_HOME/verx.x.x.x/conf/app-agent-config.xml in the fork-config section for all your FTL nodes.

`<include filter-type="EQUALS" filter-value="org.glassfish.jersey.server.ServerRuntime$AsyncResponder$2"/>`

Replace default app-agent-config.xml with your modified version in AppServerAgent-1.8-20.8.0.30686.zip

```sh
#Get path of app-agent-config.xml in ZIP-file
zipinfo AppServerAgent-1.8-20.8.0.30686.zip

#Delete dapp-agent-config.xml from ZIP-file
zip -d AppServerAgent-1.8-20.8.0.30686.zip ver20.8.0.30686/conf/app-agent-config.xml

#Add the modified app-agent-config.xml. Make sure you have the same root path on your local machine
#Example /ver20.8.0.30686/conf/custom-activity-correlation.xml
zip AppServerAgent-1.8-20.8.0.30686.zip ver20.8.0.30686/conf/app-agent-config.xml
```

### Create TIBCO BWCE base image

- Create the TIBCO BWCE base Docker images for the publisher and the subscriber.

Run bash-scripts containing the Docker commands on this location:

```/docker/<publisher or subscriber>/1_BUILD_IMAGE LOCAL Base.sh```

- Create the TIBCO application Docker images

Run bash-scripts containing the Docker commands on this location:

```/docker/<publisher or subscriber>/2_BUILD_IMAGE LOCAL APP.sh```

### Run the containers

Run bash-scripts containing the Docker commands on this location:

```/docker/<publisher or subscriber>/3_RUN_IMAGE LOCAL APP.sh```

### Test the containers

#### Run FTL cluster

- Prepare a FTL 5.4 cluster using configuration from /resources/FTL/realm.json. This configuration defines the necessary Application and Endpoints needed to run the containers.
- Start your cluster (realm & persistence servers).

```sh
#Realmserver
cd /opt/tibco/ftl/current-version/bin
sudo ./tibrealmserver --http 0.0.0.0:8080
sudo ./tibstore -n S1 -d data_dir -rs http://localhost:8080
sudo ./tibstore -n S2 -d data_dir -rs http://localhost:8080
sudo ./tibstore -n S3 -d data_dir -rs http://localhost:8080
```

#### Run BWCE containers

Run bash-scripts containing the Docker commands on this location:

```/docker/<publisher or subscriber>/3_RUN_IMAGE LOCAL APP.sh```

## Create AppDynamics Agent Properties

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
