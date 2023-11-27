/*
  managed-identity.aum.bicep
  DESCRIPTION: Creates a new Azure Managed Identity, when calling from other templates, scope should be Resourcegroup.
  AUTHOR: jthompson@lunavi.com
  DATE: 11/21/2023
  KEYWORDS: aumAccelerator

*/

param parLocation string = resourceGroup().location
param parManagedIdentityName string
param parTags object = {}

resource resManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: parManagedIdentityName
  location: parLocation
  tags: parTags
}

output outPrincipalId string = resManagedIdentity.properties.principalId
output outManagedIdentityName string = resManagedIdentity.name
output outManagedIdentityId string = resManagedIdentity.id
