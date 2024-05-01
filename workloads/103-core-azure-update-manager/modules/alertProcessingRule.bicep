/*
  alert-processing-rule.bicep
  AUTHOR: https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.recoveryservices/recovery-services-create-alert-processing-rule/main.bicep
  DATE: 11/27/2023
  DESCRIPTION: This template creates an alert processing rule and action group for the aumAccelerator.
  KEYWORDS: aumAccelerator, alert-processing-rule, alert, processing, rule, aum, lunavi.

*/


@description('Email addresses to which the notifications should be sent. Should be specified as an array of strings, for example, ["user1@contoso.com", "user2@contoso.com"].')
param parEmailAddresses array

@description('An action group is the channel to which a notification is sent, for example, email. Edit this field if you wish to use a custom name for the action group, otherwise, you can leave this unchanged. An action group name can have a length of 1-260 characters. You cannot use :,<,>,+,/,&,%,\\,? or control characters. The name cannot end with a space or period.')
param parActionGroupName string = 'ActionGroup-${resourceGroup().name}'

@description('Short name of the action group used for display purposes. Can be 1-12 characters in length.')
@maxLength(12)
param parActionGroupShortName string = 'ag-${((length(resourceGroup().name) >= 9) ? substring(resourceGroup().name, 0, 9) : resourceGroup().name)}'

@description('An alert processing rule lets you associate alerts to action groups. Edit this field if you wish to use a custom name for the alert processing rule, otherwise, you can leave this unchanged. An alert processing rule name can have a length of 1-260 characters. You cannot use <,>,*,%,&,:,\\,?,+,/,#,@,{,}.')
param parAlertProcessingRuleName string = 'AlertProcessingRule-${resourceGroup().name}'

@description('Description of the alert processing rule.')
param parAlertProcessingRuleDescription string = 'Sample alert processing rule'

@description('The scope of resources for which the alert processing rule will apply. You can leave this field unchanged if you wish to apply the rule for all Recovery Services vault within the subscription. If you wish to apply the rule on smaller scopes, you can specify an array of ARM URLs representing the scopes, eg. [\'/subscriptions/<sub-id>/resourceGroups/RG1\', \'/subscriptions/<sub-id>/resourceGroups/RG2\']')
param parAlertProcessingRuleScope array = [
  subscription().id
]

param parTags object

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: parActionGroupName
  location: 'Global'
  tags: parTags
  properties: {
    emailReceivers: [for item in parEmailAddresses: {
      name: 'emailReceivers-${uniqueString(item)}'
      emailAddress: item
      useCommonAlertSchema: true
    }]
    groupShortName: parActionGroupShortName
    enabled: true
  }
}

resource alertProcessingRule 'Microsoft.AlertsManagement/actionRules@2023-05-01-preview' = {
  name: parAlertProcessingRuleName
  location: 'Global'
  tags: parTags
  properties: {
    scopes: parAlertProcessingRuleScope

    description: parAlertProcessingRuleDescription
    enabled: true
    actions: [
      {
        actionGroupIds: [
          actionGroup.id
        ]
        actionType: 'AddActionGroups'
      }
    ]
  }
}

/* conditions: [
  {
    field: 'TargetResourceType'
    operator: 'Equals'
    values: [
      'microsoft.recoveryservices/vaults'
    ]
  }
] */




output actionGroupId string = actionGroup.id
output alertProcessingRuleId string = alertProcessingRule.id
