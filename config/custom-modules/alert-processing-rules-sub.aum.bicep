/*
  alert-processing-rules-sub.aum.bicep
  DESCRIPTION: Creates an Alert processing rule in resource group scoped to a subscription. Action group should already exist.
  AUTHOR: jthompson@lunavi.com
  DATE: 11/21/2023
  KEYWORDS: aumAccelerator
*/

param parActionRuleName string
param parActionGroupName string

param parScopes array = [
  subscription().id
]

param parTags object

resource refActionGroup 'Microsoft.Insights/actionGroups@2023-01-01' existing = {
  name: parActionGroupName
}

resource resAlertProcessingRule 'Microsoft.AlertsManagement/actionRules@2021-08-08' = {
  name: parActionRuleName
  location: 'Global'
  tags: parTags
  properties: {
    actions: [
      {
        actionType: 'AddActionGroups'
        actionGroupIds: [
          refActionGroup.id
        ]
      }
    ]
    conditions: [
      {
        field: 'Description'
        operator: 'Contains'
        values: [
          '${subscription().displayName}'
        ]
      }
    ]
    enabled: true
    scopes: parScopes
  }
}

output outAlertProcessingRuleId string = resAlertProcessingRule.id
output outAlertProcessingRuleName string = resAlertProcessingRule.name
