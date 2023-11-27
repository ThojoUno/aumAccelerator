/*
  scheduled-query-rule.aum.bicep
  DESCRIPTION: Creates a Schedule query rule.
  AUTHOR: jthompson@lunavi.com
  DATE: 11/21/2023
  KEYWORDS: aumAcelerator
*/


param parLocation string = resourceGroup().location
param parAlertName string = 'COTA PROD-PatchInstallationFailure'
param parAlertDescription string = 'Azure Update Manager has detected a status of "failed" for a recent update deployment.'
param parAlertSeverity int = 1
param parEvaluationFrequency string = 'PT5M'
param parWindowSize string = 'PT5M'
param parEnabled bool = true
param parAutoMitigate bool = false
param parIdentityType string = 'UserAssigned'
param parManagedIdentityName string
param parScopes array = []
param parAlertCriteria object = {}

param parTags object = {}

resource refManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: parManagedIdentityName
}

resource resScheduledQueryRule 'microsoft.insights/scheduledqueryrules@2023-03-15-preview' = {
  name: parAlertName
  location: parLocation
  tags: parTags
  identity: parIdentityType == 'UserAssigned' ? {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${refManagedIdentity.id}':{}
    }
  } : null
  properties: {
    displayName: parAlertName
    description: parAlertDescription
    severity: parAlertSeverity
    enabled: parEnabled
    evaluationFrequency: parEvaluationFrequency
    scopes: parScopes
    windowSize: parWindowSize
    criteria: parAlertCriteria
    autoMitigate: parAutoMitigate
  }
}
