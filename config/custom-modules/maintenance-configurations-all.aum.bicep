/*
  maintenance-configurations.aum.bicep
  This template is used to create a maintenance configurations for Azure Update Manager.
  This template expects an array of maintenance configurations to process
  Author: jthompson@lunavi.com
  Date: 11/10/2023
  KEYWORDS: aumAcelerator
*/

targetScope = 'managementGroup'

param parLocation string
// param maintenanceConfigurationName string
param parMaintenanceConfigurations array
param parSubscriptionId string
param parResourceGroupName string
param parTimeZone string = 'Central Standard Time'
param parTags object

// create maintenance configurations, this modules scope is at the resource group level since we are creating resources.
module modMaintConfigs 'maintenance-configuration.aum.bicep' = [for (mi,i) in parMaintenanceConfigurations: {
  name: mi.name
  scope: resourceGroup(parSubscriptionId,parResourceGroupName)
  params: {
    tags: parTags
    parTimeZone: parTimeZone
    parMaintenanceConfigurationName: mi.name
    parWindowsClassificationsToInclude: mi.updateClassifications
    parMaintenanceScope: mi.maintenanceScope
    parStartHour: mi.startHour
    parRecurEvery: mi.recurEvery
  }
}]

// schedule periodic updates policy assignment for each maintenance configuration.
// this uses the default management group scope since the policy assignment targets a subscription.
module modConfigAssignment '../../CARML/v0.11.0/modules/authorization/policy-assignment/main.bicep' = [for (maintCfg, i) in parMaintenanceConfigurations: {
  name: '${uniqueString(deployment().name, parLocation,maintCfg.name)}-policyAssignment-${i}'
  dependsOn: [
    modMaintConfigs
  ]
  params: {
    name: maintCfg.name
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/ba0df93e-e4ac-479a-aac2-134bbae39a1a'
    subscriptionId: parSubscriptionId
    identity: 'SystemAssigned'
    location: parLocation
    roleDefinitionIds: [
      '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    ]
    parameters: {
      maintenanceConfigurationResourceId: {
        value: '/subscriptions/${parSubscriptionId}/resourceGroups/${parResourceGroupName}/providers/Microsoft.maintenance/maintenanceConfigurations/${maintCfg.name}'
      }
    }
  }
}]
