/*
  maintenanceConfiguration.bicep
  This template is used to create a maintenance configuration for Azure Update Manager.
  Author: jthompson@lunavi.com
  Date: 11/10/2023

  Updated: 2024/04/30

*/

param parLocation string = resourceGroup().location
param parMaintenanceConfigurationName string
param parRecurEvery string = 'Month First Wednesday'
param parStartDate string = utcNow('yyyy-MM-dd')
param parStartHour string = '00:00'
param parWindowsClassificationsToInclude array = [
  'Critical'
  'ServicePack'
  'Security'
  'UpdateRollup'
  'Updates'
]
param parInGuestPatchMode string = 'User'
param parRebootSetting string = 'IfRequired'
param parMaintenanceScope string = 'InGuestPatch'
param parDuration string = '03:00'
param parExpirationDateTime string = ''
param parTimeZone string = 'Central Standard Time'
param parKbNumbersToInclude array = []
param parKbNumbersToExclude array = []


param parTags object

module maintenanceConfiguration 'br/public:avm/res/maintenance/maintenance-configuration:0.1.2' = {
  name: '${uniqueString(deployment().name, parLocation)}-MaintConfigDeployment'
  params: {
    // Required parameters
    name: parMaintenanceConfigurationName
    // Non-required parameters
    extensionProperties: {
      InGuestPatchMode: parInGuestPatchMode
    }
    installPatches: {
      // linuxParameters: {
      //   classificationsToInclude: '<classificationsToInclude>'
      //   packageNameMasksToExclude: '<packageNameMasksToExclude>'
      //   packageNameMasksToInclude: '<packageNameMasksToInclude>'
      // }
      rebootSetting: parRebootSetting
      windowsParameters: {
        classificationsToInclude: parWindowsClassificationsToInclude
        kbNumbersToExclude: parKbNumbersToExclude
        kbNumbersToInclude: parKbNumbersToInclude
      }
    }
    location: parLocation
    maintenanceScope: parMaintenanceScope
    maintenanceWindow: {
      duration: parDuration
      expirationDateTime: parExpirationDateTime
      recurEvery: parRecurEvery
      startDateTime: '${parStartDate} ${parStartHour}'
      timeZone: parTimeZone
    }
    tags: parTags
    visibility: 'Custom'
  }
}

output outMaintenanceConfigName string = maintenanceConfiguration.outputs.name
output outMaintenanceConfigId string = maintenanceConfiguration.outputs.resourceId
output outMaintenanceconfigResourceGroupName string = maintenanceConfiguration.outputs.resourceGroupName
