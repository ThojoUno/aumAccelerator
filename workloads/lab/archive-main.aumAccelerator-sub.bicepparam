
/*

This Bicep parameter file has been replaced, use main.bicepparam file in workloads folder.


*/

using '../../config/custom-modules/main.aumAccelerator-sub.bicep'

/*
  This Azure Update Manager accelerator should be deployed after the Logging resources,
  as part of an Azure Landing Zone deployment.

  This version is subscription based.

  aumSettings.checkUpdatePolicy is assigned to the topLevelManagementGroupPrefix
  aumSettings.checkUpdatePolicy.enabled - Should normally leave as true, but can set to false for testing purposes.

  aumSettings.managedIdentity.roleDefinitionId - '73c42c96-874c-492b-b04d-ab87d138a893' is "Log Analytics Reader" role required for scheduledQueryRule based alerts.
  aumSettings.managedIdentity.enabled - Should typically leave this as true, but can set to false for testing purposes.

*/

param aumSettings = {
  topLevelManagementGroupPrefix: 'ESLZ'
  timeZone: 'Pacific Standard Time'
  checkUpdatePolicy: {
    enabled: true
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/59efceea-0c96-497e-a4a1-4eb2290dac15'
    policyAssignmentName: 'Check_missing_updates'
    policyAssignmentDisplayName: 'Check missing updates'
    policyAssignmentDescription: 'Check for missing updates on Windows VMs'
    policyAssignmentIdentityType: 'SystemAssigned'
  }
  subscriptions: [
    {
      subscriptionId: '00000000-0000-0000-0000-000000000000'
      subscriptionName: 'Lab-Hub-Sandbox'
      resourceGroupName: 'rg-westus2-UpdateManager-hub'
      tags: {
        Environment: 'Hub-Lab'
        _deployed_by_aumAccelerator: 'true'

      }
      maintenanceConfigurations: [
        {
          name: 'mc-win-hub-definitions-daily-0000'
          updateClassifications: [
            'Definition'
          ]
          recurEvery: 'Day'
          startHour: '00:00'
          duration: '03:00'
          excludeKbsRequiringReboot: false
          maintenanceScope: 'InGuestPatch'
        }
        {
          name: 'mc-win-hub-3rd-Wed-0000'
          updateClassifications: [
            'Critical'
            'ServicePack'
            'Security'
            'UpdateRollup'
            'Updates'
          ]
          recurEvery: 'Month Third Wednesday'
          startHour: '00:00'
          duration: '03:00'
          excludeKbsRequiringReboot: false
          maintenanceScope: 'InGuestPatch'
        }
      ]
      managedIdentity: {
        enabled: true
        name: 'mi-lawsReader-hub'
        roleDefinitionId: '73c42c96-874c-492b-b04d-ab87d138a893'
      }
      actionGroup: {
        enabled: true
        name: 'ag-AumAccelerator-hub'
        shortName: 'aumActionGrp'
        emailReceivers: [
          'jthompson@lunavi.com'
        ]
      }
      alertProcessingRule: {
        name: 'Hub-Update Manager Alert Processing Rule'
        description: 'Hub Update Manager Alert Processing Rule'
        enabled: true
      }
    }
    {
      subscriptionId: '00000000-0000-0000-0000-000000000000'
      subscriptionName: 'Lab-Prod-Sandbox'
      resourceGroupName: 'rg-westus2-UpdateManager-prod'
      tags: {
        Environment: 'Prod-Lab'
        _deployed_by_aumAccelerator: 'true'
      }
      maintenanceConfigurations: [
        {
          name: 'mc-win-prod-definitions-daily-0000'
          updateClassifications: [
            'Definition'
          ]
          recurEvery: 'Day'
          startHour: '00:00'
          duration: '03:00'
          excludeKbsRequiringReboot: false
          maintenanceScope: 'InGuestPatch'
        }
        {
          name: 'mc-win-prod-1st-Wed-0000'
          updateClassifications: [
            'Critical'
            'ServicePack'
            'Security'
            'UpdateRollup'
            'Updates'
          ]
          recurEvery: 'Month First Wednesday'
          startHour: '00:00'
          duration: '03:00'
          excludeKbsRequiringReboot: false
          maintenanceScope: 'InGuestPatch'
        }
      ]
      managedIdentity: {
        enabled: true
        name: 'mi-lawsReader-prod'
        roleDefinitionId: '73c42c96-874c-492b-b04d-ab87d138a893'
      }
      actionGroup: {
        enabled: true
        name: 'ag-aumAccelerator-prod'
        shortName: 'aumActionGrp'
        emailReceivers: [
          'jthompson@lunavi.com'
        ]
      }
      alertProcessingRule: {
        name: 'Prod-Update Manager Alert Processing Rule'
        description: 'Production Update Manager Alert Processing Rule'
        enabled: true
      }
    }
  ]
  alerts: {
    pendingUpdates: {
      name: 'Pending security and critical updates'
      description: 'Pending security and critical updates scheduled query rule.'
      enabled: true
      evaluationFrequency: 'PT6H'
      windowSize: 'PT6H'
      severity: 2
      alertCriteria: {
        allOf: [
          {
            query: '// Filtering by subscriptionId, resourceGroup, location, and other criteria can be applied as needed.\narg(\'\').patchassessmentresources\n| where type in~ ("microsoft.compute/virtualmachines/patchassessmentresults", "microsoft.hybridcompute/machines/patchassessmentresults")\n| where properties.status =~ "Succeeded"\n| extend securityOrCriticalUpdatesCount =\n    iff(properties.osType =~ "Windows",\n    (toint(properties.availablePatchCountByClassification.security) +\n    toint(properties.availablePatchCountByClassification.critical)),\n    toint(properties.availablePatchCountByClassification.security))\n| where securityOrCriticalUpdatesCount > 0\n| extend vmResourceId = tostring(split(id, "/patchAssessmentResults/")[0])\n| project vmResourceId\n'
            timeAggregation: 'Count'
            dimensions: []
            operator: 'GreaterThan'
            threshold: 1
            failingPeriods: {
              numberOfEvaluationPeriods: 1
              minFailingPeriodsToAlert: 1
            }
          }
        ]
      }
      autoMitigate: true
    }
    assessmentFailures: {
      name: 'Assessment failures'
      description: 'Patch assessment failures scheduled query rule.'
      enabled: true
      evaluationFrequency: 'PT6H'
      windowSize: 'PT6H'
      severity: 2
      alertCriteria: {
        allOf: [
          {
            query: '''arg('').patchassessmentresources
            | where type in~ ("microsoft.compute/virtualmachines/patchassessmentresults", "microsoft.hybridcompute/machines/patchassessmentresults")
            | where properties.status =~ "Failed" // "CompletedWithWarnings" and other statuses can also be considered
            | where properties.lastModifiedDateTime > ago(1d)
            | parse id with vmResourceId "/patchAssessmentResults" *
            | project vmResourceId'''
            timeAggregation: 'Count'
            dimensions: []
            operator: 'GreaterThan'
            threshold: 1
            failingPeriods: {
              numberOfEvaluationPeriods: 1
              minFailingPeriodsToAlert: 1
            }
          }
        ]
      }
      autoMitigate: true
    }
    installationFailures: {
      name: 'Patch installation failures'
      description: 'Patch installation failures scheduled query rule.'
      enabled: true
      evaluationFrequency: 'PT6H'
      windowSize: 'PT6H'
      severity: 2
      alertCriteria: {
        allOf: [
          {
            query: '''arg('').patchinstallationresources
              | where type in~ ("microsoft.compute/virtualmachines/patchinstallationresults", "microsoft.hybridcompute/machines/patchinstallationresults")
              | where properties.status =~ "Failed" // "CompletedWithWarnings" and other statuses can also be considered
              | where properties.lastModifiedDateTime > ago(1d)
              | parse id with vmResourceId "/patchInstallationResults" *
              | project vmResourceId
              | distinct vmResourceId'''
            timeAggregation: 'Count'
            dimensions: []
            operator: 'GreaterThan'
            threshold: 1
            failingPeriods: {
              numberOfEvaluationPeriods: 1
              minFailingPeriodsToAlert: 1
            }
          }
        ]
      }
      autoMitigate: true
    }
  }

}

