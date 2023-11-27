/*
  role-assignment-subscription.aum.bicep
  DESCRIPTION: Assigns an managed identity role at a Subscription level
  AUTHOR: jthompson@lunavi.com
  DATE: 11/21/2023
  KEYWWORDS: aumAccelerator
*/

targetScope = 'subscription'

param parRoleDefinitionId string

@description('principalId if the user that will be given contributor access to the resourceGroup')
param parPrincipalId string

var varRoleAssignmentName = guid(subscription().id, parPrincipalId, parRoleDefinitionId)

// Role Assignment for Deployment Script Contributor
resource resRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: varRoleAssignmentName
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', parRoleDefinitionId)
    principalId: parPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output outRoleAssignmentId string = resRoleAssignment.id
output outRoleAssignmentName string = resRoleAssignment.name
