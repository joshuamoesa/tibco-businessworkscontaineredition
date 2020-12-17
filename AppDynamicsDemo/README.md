# AppDynamicsDemo

## Create AppDynamics Agent Properties

Go to Tiers & Nodes > Actions: Configure App Server Agent. Click on your node. Select Use *Custom Configuration*. Add a property by clicking the +-sign. Click on Save to commit the changes.

Use the following settings:
* Name: error-safety-rule-error-threshold
* Description: Make sure that the instrumentation is not neutralized during the first 15 minutes of the application startup when there is no singularityheader set in the FTL messages.
* Type: Integer
* Value: -1

References:

[AppDynamics: App Agent Node Properties](https://docs.appdynamics.com/display/PRO45/App+Agent+Node+Properties)
