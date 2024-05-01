/*
  main.bicep
  DESCRIPTION: Bicep template will deploy all prerequisites for Azure Update Manager.
  AUTHOR: jthompson@lunavi.com
  DATE: 11/21/2023
  KEYWORDS: aumAccelerator, Azure Update Manager, Azure Policy, Azure Monitor, Azure Resource Manager, Bicep

  This template is scoped to the top level management group root, which is typically the intermediate management group under the root management group.
  Most modules are scoped at the management group level by default, but some modules are scoped at the subscription and resource group level.

*/

targetScope = 'managementGroup'

@sys.description('Deployment location')
param parLocation string = deployment().location

@description('Required: Accelerator settings object from bicepparam parameters file.')
param parAumSettings object

@description('Required: Azure policies to assign to enable Azure Update Manager.')
param parPolicyAssignments object

// Use Alz-Bicep module for Management group policy assignment.
// Assign period checking for updates policy to management group.
module modPeriodicAssessment '../../upstream-releases/v0.17.2/infra-as-code/bicep/modules/policy/assignments/policyAssignmentManagementGroup.bicep' = if (parPolicyAssignments.checkUpdatePolicy.enabled) {
  name: '${uniqueString(deployment().name, parLocation)}-mg-policy-periodicAssessment'
  params: {
    parPolicyAssignmentDefinitionId: parPolicyAssignments.checkUpdatePolicy.policyDefinitionId
    parPolicyAssignmentDescription: parPolicyAssignments.checkUpdatePolicy.policyAssignmentDescription
    parPolicyAssignmentDisplayName: parPolicyAssignments.checkUpdatePolicy.policyAssignmentDisplayName
    parPolicyAssignmentName: parPolicyAssignments.checkUpdatePolicy.policyAssignmentName
    parPolicyAssignmentIdentityType: parPolicyAssignments.checkUpdatePolicy.policyAssignmentIdentityType
  }
}

// Create resource group in each subscription for AUM maintenance configurations, managed identity, and alert rules.
// Resource group creation should always be scoped to a subscription
module modResourceGroups 'br/public:avm/res/resources/resource-group:0.2.3' = [for (sub, i) in parAumSettings.subscriptions: {
  scope: subscription(sub.subscriptionId)
  name: '${uniqueString(deployment().name, parLocation)}-AzureUpdateManager-rg-${i}'
  params: {
    location: parLocation
    name: sub.resourceGroupName
    tags: sub.tags
  }
}]

// Create all defined maintenance configurations in bicepparam file.
// This module also creates the Azure Policy assignments for each maintenance configuration,
// so the module must be scoped at the management group level, which is the default scope.
module modMaintConfigs './modules/maintenanceConfiguration.all.bicep' = [for (sub, i) in parAumSettings.subscriptions: {
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
    parTimeZone: parAumSettings.timeZone
  }
}]

// Create user assigned managed identity required for AUM alerting.
module modLawsIdentity './modules/managedIdentity.bicep' = [for (sub, i) in parAumSettings.subscriptions: {
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

// Assign "Log Analytics Reader" role to subscriptions scope in scheduled query rule alerts.
module modRoleAssignment './modules/managedIdentityRoleAssignmentSubscription.bicep' = [for (sub, i) in parAumSettings.subscriptions : {
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
module modAlertProcessingRules './modules/alertProcessingRule.bicep' = [for (sub, i) in parAumSettings.subscriptions :{
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
module modPendingUpdatesAlert './modules/scheduledQueryRule.bicep' = [for (sub, i) in parAumSettings.subscriptions : {
  scope: resourceGroup(sub.subscriptionId,sub.resourceGroupName)
  name: '${uniqueString(deployment().name, parLocation)}-pendingUpdates-${i}'
  dependsOn: [
    modRoleAssignment
  ]
  params: {
    parLocation: parLocation
    parTags: sub.tags
    parAlertName: '${sub.subscriptionName}-${parAumSettings.alerts.pendingUpdates.name}'
    parAlertDescription: parAumSettings.alerts.pendingUpdates.description
    parAlertSeverity: parAumSettings.alerts.pendingUpdates.severity
    parEvaluationFrequency: parAumSettings.alerts.pendingUpdates.evaluationFrequency
    parWindowSize: parAumSettings.alerts.pendingUpdates.windowSize
    parAlertCriteria: parAumSettings.alerts.pendingUpdates.alertCriteria
    parAutoMitigate: parAumSettings.alerts.pendingUpdates.autoMitigate
    parManagedIdentityName: sub.managedIdentity.name
    parScopes: [
      '/subscriptions/${sub.subscriptionId}'
    ]
  }
}]

// Create assessment failures alert
module modAssessmentFailuresAlert './modules/scheduledQueryRule.bicep' = [for (sub, i) in parAumSettings.subscriptions : {
  scope: resourceGroup(sub.subscriptionId,sub.resourceGroupName)
  name: '${uniqueString(deployment().name, parLocation)}-assessmentFailures-${i}'
  dependsOn: [
    modRoleAssignment
  ]
  params: {
    parLocation: parLocation
    parTags: sub.tags
    parAlertName: '${sub.subscriptionName}-${parAumSettings.alerts.assessmentFailures.name}'
    parAlertDescription: parAumSettings.alerts.assessmentFailures.description
    parAlertSeverity: parAumSettings.alerts.assessmentFailures.severity
    parEvaluationFrequency: parAumSettings.alerts.assessmentFailures.evaluationFrequency
    parWindowSize: parAumSettings.alerts.assessmentFailures.windowSize
    parAlertCriteria: parAumSettings.alerts.assessmentFailures.alertCriteria
    parAutoMitigate: parAumSettings.alerts.assessmentFailures.autoMitigate
    parManagedIdentityName: sub.managedIdentity.name
    parScopes: [
      '/subscriptions/${sub.subscriptionId}'
    ]
  }
}]


// Create Patch installation failures alert
module modInstallationFailuresAlert './modules/scheduledQueryRule.bicep' = [for (sub, i) in parAumSettings.subscriptions : {
  scope: resourceGroup(sub.subscriptionId,sub.resourceGroupName)
  name: '${uniqueString(deployment().name, parLocation)}-installationFailures-${i}'
  dependsOn: [
    modRoleAssignment
  ]
  params: {
    parLocation: parLocation
    parTags: sub.tags
    parAlertName: '${sub.subscriptionName}-${parAumSettings.alerts.installationFailures.name}'
    parAlertDescription: parAumSettings.alerts.installationFailures.description
    parAlertSeverity: parAumSettings.alerts.installationFailures.severity
    parEvaluationFrequency: parAumSettings.alerts.installationFailures.evaluationFrequency
    parWindowSize: parAumSettings.alerts.installationFailures.windowSize
    parAlertCriteria: parAumSettings.alerts.installationFailures.alertCriteria
    parAutoMitigate: parAumSettings.alerts.installationFailures.autoMitigate
    parManagedIdentityName: sub.managedIdentity.name
    parScopes: [
      '/subscriptions/${sub.subscriptionId}'
    ]
  }
}]
