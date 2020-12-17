# AppDynamicsDemo

## Prepare TIBCO BWCE base image

### Replace AppDynamics javaagent configuration files

#### Replace default custom-activity-correlation.xml

Replace default custom-activity-correlation.xml with the proposed version [1] in AppServerAgent-1.8-20.8.0.30686.zip

```sh
#Get path of custom-activity-correlation.xml in ZIP-file
zipinfo AppServerAgent-1.8-20.8.0.30686.zip

#Delete default custom-activity-correlation.xml from ZIP-file
zip -d AppServerAgent-1.8-20.8.0.30686.zip ver20.8.0.30686/conf/custom-activity-correlation.xml
   
#Add the new custom-activity-correlation.xml. Make sure you have the same root path on your local machine
#Example /ver20.8.0.30686/conf/custom-activity-correlation.xml
zip AppServerAgent-1.8-20.8.0.30686.zip ver20.8.0.30686/conf/custom-activity-correlation.xml
```

#### Replace default app-agent-config.xml

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

## Create AppDynamics Agent Properties

In AppDynamics UI go to Tiers & Nodes > Actions: Configure App Server Agent. Click on your node. Select Use *Custom Configuration*. Add a property by clicking the +-sign. Click on Save to commit the changes.

Use the following settings:
* Name: error-safety-rule-error-threshold
* Description: Make sure that the instrumentation is not neutralized during the first 15 minutes of the application startup when there is no singularityheader set in the FTL messages.
* Type: Integer
* Value: -1

References:
* [AppDynamics: App Agent Node Properties](https://docs.appdynamics.com/display/PRO45/App+Agent+Node+Properties)

## References
[1] [AppDynamics: Howto instrument and correlate TIBCO FTL exit calls in TIBCO](https://community.appdynamics.com/t5/Knowledge-Base/How-do-I-instrument-and-correlate-TIBCO-FTL-exit-calls-in-TIBCO/ta-p/33621)
[2] [AppDynamics: How to get visibility into TIBCO with APM](https://www.appdynamics.com/blog/product/how-to-get-visibility-into-tibco-with-apm/)

