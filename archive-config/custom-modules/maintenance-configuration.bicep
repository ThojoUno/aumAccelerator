/*
  maintenance-configuration.aum.bicep
  This template is used to create a maintenance configuration for Azure Update Manager.
  Author: jthompson@lunavi.com
  Date: 11/10/2023

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

param tags object

resource resMaintenanceConfig 'Microsoft.Maintenance/maintenanceConfigurations@2023-09-01-preview' = {
  name: parMaintenanceConfigurationName
  location: parLocation
  tags: tags
  properties: {
    extensionProperties: {
      InGuestPatchMode: parInGuestPatchMode
    }
    installPatches: {
      rebootSetting: parRebootSetting
      windowsParameters: {
        classificationsToInclude: parWindowsClassificationsToInclude
        excludeKbsRequiringReboot: false
        kbNumbersToExclude: []
        kbNumbersToInclude: []
      }
    }
    maintenanceScope: parMaintenanceScope
    maintenanceWindow: {
      duration: parDuration
      expirationDateTime: parExpirationDateTime
      recurEvery: parRecurEvery
      startDateTime: '${parStartDate} ${parStartHour}'
      timeZone: parTimeZone
    }
    visibility: 'Custom'
  }
}

output outMaintenanceConfigName string = resMaintenanceConfig.name
output outMaintenanceConfigId string = resMaintenanceConfig.id
