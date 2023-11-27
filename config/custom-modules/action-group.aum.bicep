/*
  action-group.aum.bicep
  DESCRIPTION: Create Action Group in resource group.
  AUTHOR: jthompson@lunavi.com
  DATE: 11/21/2023
  KEYWORDS: aumAccelerator
*/

param parActionGroupName string
param parActionGroupShortName string
param parEmailReceivers array
param parTags object

resource resActionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: parActionGroupName
  location: 'Global'
  tags: parTags
  properties: {
    enabled: true
    groupShortName: parActionGroupShortName
    emailReceivers: parEmailReceivers
  }
}

output outActionGroupId string = resActionGroup.id
output outActionGroupName string = resActionGroup.name
