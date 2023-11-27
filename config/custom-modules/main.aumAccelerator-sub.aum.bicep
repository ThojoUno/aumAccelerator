/*
  main.aumAcceleratorSub.aum.bicep
  DESCRIPTION: Bicep template will deploy all prerequisites for Azure Update Manager.
  AUTHOR: jthompson@lunavi.com
  DATE: 11/21/2023
  KEYWORDS: aumAccelerator, Azure Update Manager, Azure Policy, Azure Monitor, Azure Resource Manager, Bicep

  This template is scoped to the top level management group root, which is typically the intermediate management group under the root management group.
  Most modules are scoped at the management group level by default, but some modules are scoped at the subscription and resource group level.

*/

targetScope = 'managementGroup'

@description('Settings from bicepparam parameters file.')
param aumSettings object

param parLocation string = deployment().location

// Use Alz-Bicep module for Management group policy assignment.
// Assign period checking for updates policy to management group.
module modPeriodicAssessment '../../infra-as-code/bicep/modules/policy/assignments/policyAssignmentManagementGroup.bicep' = if (aumSettings.checkUpdatePolicy.enabled) {
  name: '${uniqueString(deployment().name, parLocation)}-mg-policy-periodicAssessment'
  params: {
    parPolicyAssignmentDefinitionId: aumSettings.checkUpdatePolicy.policyDefinitionId
    parPolicyAssignmentDescription: aumSettings.checkUpdatePolicy.policyAssignmentDescription
    parPolicyAssignmentDisplayName: aumSettings.checkUpdatePolicy.policyAssignmentDisplayName
    parPolicyAssignmentName: aumSettings.checkUpdatePolicy.policyAssignmentName
    parPolicyAssignmentIdentityType: aumSettings.checkUpdatePolicy.policyAssignmentIdentityType
  }
}

// Create resource group in each subscription for AUM maintenance configurations, managed identity, and alert rules.
module modResourceGroups '../../infra-as-code/bicep/modules/resourceGroup/resourceGroup.bicep' = [for (sub, i) in aumSettings.subscriptions: {
  name: '${uniqueString(deployment().name, parLocation)}-rg-aumAccelerator-${i}'
  scope: subscription(sub.subscriptionId)
  params: {
    parLocation: parLocation
    parResourceGroupName: sub.resourceGroupName
    parTags: sub.tags
  }
}]

// Create all defined maintenance configurations in bicepparam file.
// This module also creates the Azure Policy assignments for each maintenance configuration,
// so the module must be scoped at the management group level, which is the default scope.
module modMaintConfigs 'maintenance-configurations-all.aum.bicep' = [for (sub, i) in aumSettings.subscriptions: {
  name: '${uniqueString(deployment().name, parLocation)}-maintenanceConfigurations-${i}'
  dependsOn: [
    modResourceGroups
  ]
  params: {
    parTags: sub.tags
    parLocation: parLocation
    parSubscriptionId: sub.subscriptionId
    parResourceGroupName: sub.resourceGroupName
    parMaintenanceConfigurations: sub.maintenanceConfigurations
    parTimeZone: aumSettings.timeZone
  }
}]

// Create user assigned managed identity required for AUM alerting.
module modLawsIdentity 'managed-identity.aum.bicep' = [for (sub, i) in aumSettings.subscriptions: {
  name: '${uniqueString(deployment().name, parLocation)}-userAssignedIdentity-${i}'
  scope: resourceGroup(sub.subscriptionId,sub.resourceGroupName)
  dependsOn: [
    modResourceGroups
  ]
  params: {
    parTags: sub.tags
    parManagedIdentityName: sub.managedIdentity.name
  }
}]

// Assign "Log Analytics Reader" role to subscriptions set as scope in scheduled query rule alerts.
module modRoleAssignment 'managed-identity-role-assignment-sub.aum.bicep' = [for (sub, i) in aumSettings.subscriptions : {
  name: '${uniqueString(deployment().name, parLocation)}-userAssignedIdentity-roleAssignment-${i}'
  scope: subscription(sub.subscriptionId)
  dependsOn: [
    modLawsIdentity
  ]
  params: {
    parManagedIdentityName: sub.managedIdentity.name
    parMiSubscriptionId: sub.subscriptionId
    parMiResourceGroupName: sub.resourceGroupName
    parRoleDefinitionId: sub.managedIdentity.roleDefinitionId
  }
}]

// create Action group for AUM alerts.
// Using Microsoft public Bicep registry module.
// module modActionGroup 'br/public:avm/res/insights/action-group:0.2.1' = {
//   name: '${uniqueString(deployment().name, parLocation)}-actionGroup'
//   scope: resourceGroup(aumSettings.subscriptionId,aumSettings.resourceGroupName)
//   dependsOn: [
//     modAcceleratorRg
//   ]
//   params: {
//     name: aumSettings.actionGroup.name
//     groupShortName: aumSettings.actionGroup.shortName
//     emailReceivers: aumSettings.actionGroup.emailRecievers
//   }
// }

module modActionGroup 'action-group.aum.bicep' = [for (sub, i) in aumSettings.subscriptions : {
  name: '${uniqueString(deployment().name, parLocation)}-actionGroup-${i}'
  scope: resourceGroup(sub.subscriptionId,sub.resourceGroupName)
  dependsOn: [
    modResourceGroups
  ]
  params: {
    parTags: sub.tags
    parActionGroupName: sub.actionGroup.name
    parActionGroupShortName: sub.actionGroup.shortName
    parEmailReceivers: sub.actionGroup.emailReceivers
  }
}]

// Create pending updates alert via scheduled query rule.
module modPendingUpdatesAlert 'scheduled-query-rule.aum.bicep' = [for (sub, i) in aumSettings.subscriptions : {
  scope: resourceGroup(sub.subscriptionId,sub.resourceGroupName)
  name: '${uniqueString(deployment().name, parLocation)}-pendingUpdates-${i}'
  dependsOn: [
    modRoleAssignment
  ]
  params: {
    parTags: sub.tags
    parAlertName: '${sub.subscriptionName}-${aumSettings.alerts.pendingUpdates.name}'
    parAlertDescription: aumSettings.alerts.pendingUpdates.description
    parAlertSeverity: aumSettings.alerts.pendingUpdates.severity
    parEvaluationFrequency: aumSettings.alerts.pendingUpdates.evaluationFrequency
    parWindowSize: aumSettings.alerts.pendingUpdates.windowSize
    parAlertCriteria: aumSettings.alerts.pendingUpdates.alertCriteria
    parAutoMitigate: aumSettings.alerts.pendingUpdates.autoMitigate
    parManagedIdentityName: sub.managedIdentity.name
    parScopes: [
      '/subscriptions/${sub.subscriptionId}'
    ]
  }
}]

// Create assessment failures alert

// Create Patch installation failures alert

// Create Alert processing rule
module modAlertProcessingRules 'alert-processing-rules-sub.aum.bicep' = [for (sub, i) in aumSettings.subscriptions :{
  name: '${uniqueString(deployment().name, parLocation)}-alertProcessingRule-${i}'
  scope: resourceGroup(sub.subscriptionId,sub.resourceGroupName)
  dependsOn: [
    modResourceGroups
  ]
  params: {
    parTags: sub.tags
    parActionRuleName: sub.actionRule.name
    parActionGroupName: sub.actionGroup.name
  }
}]
