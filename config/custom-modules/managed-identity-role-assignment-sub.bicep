/*
  managed-identity-role-assignment-sub.bicep
  DESCRIPTION: Assigns an managed identity role at a Subscription level
  AUTHOR: jthompson@lunavi.com
  DATE: 11/21/2023
  KEYWWORDS: aumAccelerator
*/

targetScope = 'subscription'

@description('Name of the role definition to assign to the managed identity')
param parRoleDefinitionId string

@description('Name of the managed identity')
param parManagedIdentityName string

@description('Name of the resource group containing managed identity.')
param parMiResourceGroupName string

@description('Subscription Id of the resource group containing managed identity.')
param parMiSubscriptionId string

@description('Get reference to existing user assigned managed identity.')
resource refIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(parMiSubscriptionId, parMiResourceGroupName)
  name: parManagedIdentityName
}

var varRoleAssignmentName = guid(subscription().id, parManagedIdentityName, parRoleDefinitionId)

// Role Assignment for Deployment Script Contributor
resource resRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: varRoleAssignmentName
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', parRoleDefinitionId)
    principalId: refIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output outRoleAssignmentId string = resRoleAssignment.id
output outRoleAssignmentName string = resRoleAssignment.name
