/*
  main.aumAccelerator-sub.bicep
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
module modMaintConfigs './maintenance-configurations-all.bicep' = [for (sub, i) in aumSettings.subscriptions: {
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
// module modLawsIdentity 'managed-identity.lunavi.bicep' = if (aumSettings.managedIdentity.enabled) {
module modLawsIdentity './managed-identity.bicep' = [for (sub, i) in aumSettings.subscriptions: {
  name: '${uniqueString(deployment().name, parLocation)}-userAssignedIdentity-${i}'
  scope: resourceGroup(sub.subscriptionId,sub.resourceGroupName)
  dependsOn: [
    modResourceGroups
  ]
  params: {
    parLocation: parLocation
    parTags: sub.tags
    parManagedIdentityName: sub.managedIdentity.name
  }
}]

// Assign "Log Analytics Reader" role to subscriptions set as scope in scheduled query rule alerts.
module modRoleAssignment './managed-identity-role-assignment-sub.bicep' = [for (sub, i) in aumSettings.subscriptions : {
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

// move to consolidated action group/alert processing rule module
module modAlertProcessingRules './alert-processing-rule.bicep' = [for (sub, i) in aumSettings.subscriptions :{
  name: '${uniqueString(deployment().name, parLocation)}-alertProcessingRule-${i}'
  scope: resourceGroup(sub.subscriptionId,sub.resourceGroupName)
  dependsOn: [
    modResourceGroups
  ]
  params: {
    parTags: sub.tags
    parEmailAddresses: sub.actionGroup.emailReceivers
    parActionGroupName: sub.actionGroup.name
    parActionGroupShortName: sub.actionGroup.shortName
    parAlertProcessingRuleName: sub.alertProcessingRule.name
    parAlertProcessingRuleDescription: sub.alertProcessingRule.description
  }
}]

// Create pending updates alert via scheduled query rule.
module modPendingUpdatesAlert './scheduled-query-rule.bicep' = [for (sub, i) in aumSettings.subscriptions : {
  scope: resourceGroup(sub.subscriptionId,sub.resourceGroupName)
  name: '${uniqueString(deployment().name, parLocation)}-pendingUpdates-${i}'
  dependsOn: [
    modRoleAssignment
  ]
  params: {
    parLocation: parLocation
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
module modAssessmentFailuresAlert './scheduled-query-rule.bicep' = [for (sub, i) in aumSettings.subscriptions : {
  scope: resourceGroup(sub.subscriptionId,sub.resourceGroupName)
  name: '${uniqueString(deployment().name, parLocation)}-assessmentFailures-${i}'
  dependsOn: [
    modRoleAssignment
  ]
  params: {
    parLocation: parLocation
    parTags: sub.tags
    parAlertName: '${sub.subscriptionName}-${aumSettings.alerts.assessmentFailures.name}'
    parAlertDescription: aumSettings.alerts.assessmentFailures.description
    parAlertSeverity: aumSettings.alerts.assessmentFailures.severity
    parEvaluationFrequency: aumSettings.alerts.assessmentFailures.evaluationFrequency
    parWindowSize: aumSettings.alerts.assessmentFailures.windowSize
    parAlertCriteria: aumSettings.alerts.assessmentFailures.alertCriteria
    parAutoMitigate: aumSettings.alerts.assessmentFailures.autoMitigate
    parManagedIdentityName: sub.managedIdentity.name
    parScopes: [
      '/subscriptions/${sub.subscriptionId}'
    ]
  }
}]


// Create Patch installation failures alert
module modInstallationFailuresAlert './scheduled-query-rule.bicep' = [for (sub, i) in aumSettings.subscriptions : {
  scope: resourceGroup(sub.subscriptionId,sub.resourceGroupName)
  name: '${uniqueString(deployment().name, parLocation)}-installationFailures-${i}'
  dependsOn: [
    modRoleAssignment
  ]
  params: {
    parLocation: parLocation
    parTags: sub.tags
    parAlertName: '${sub.subscriptionName}-${aumSettings.alerts.installationFailures.name}'
    parAlertDescription: aumSettings.alerts.installationFailures.description
    parAlertSeverity: aumSettings.alerts.installationFailures.severity
    parEvaluationFrequency: aumSettings.alerts.installationFailures.evaluationFrequency
    parWindowSize: aumSettings.alerts.installationFailures.windowSize
    parAlertCriteria: aumSettings.alerts.installationFailures.alertCriteria
    parAutoMitigate: aumSettings.alerts.installationFailures.autoMitigate
    parManagedIdentityName: sub.managedIdentity.name
    parScopes: [
      '/subscriptions/${sub.subscriptionId}'
    ]
  }
}]

