# Azure Update Manager Accelerator (aumAccelerator)
The Azure Update Manager Accelerator (aumAccelerator) is a set of Azure Bicep templates for implementing all the Azure policies, maintenance configurations, alert rules, action groups, and alert processing rules required to manage software updates of Windows virtual machines in Azure, or Azure Arc-enabled virtual machines on-premise at scale. [Azure Update Manager](https://learn.microsoft.com/en-us/azure/update-manager/overview?tabs=azure-vms) is replacing Azure Update Management with Azure Automation, which is [retiring August 2024](https://azure.microsoft.com/en-us/updates/were-retiring-the-log-analytics-agent-in-azure-monitor-on-31-august-2024/).

This accelerator is designed to be deployed in an Azure Landing Zone (ALZ) environment on a per-subscription basis. This allows for different configurations based on application subscriptions, production subscriptions and other non-production subscriptions. For non-production subscriptions, you can scheduled the deployment of software updates based on Patch Tuesday, which is the 2nd Tuesday of the month. Then schedule virtual machine resources separately for production subscriptions. This allows you to test software updates in non-production environments before deploying to production environments.

This accelerator also deploys a separate maintenance configuration that will deploy Microsoft anti-malware (Defender) definitions on an hourly, or daily basis.

Alerts are configured to notify you when software updates are available, and when software updates are installed. Alerts are also configured to notify you if a patch assessment or software update deployment has failed. Alert severity is configurable. Pre-warning, alerting is still a work in progress, but the basics are included.

## Prerequisites
The aumAccelerator uses a number of Bicep modules from the [ALZ-Bicep](https://github.com/Azure/ALZ-Bicep/) Github repository, and from the [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/) library.

### ALZ-Bicep
I recommend you start with the [ALZ-Bicep accelerator](https://github.com/Azure/ALZ-Bicep/wiki/Accelerator), which will give you the basic framework for successfully implementing the aumAccelerator. After you complete the steps to implement the ALL-Bicep accelerator, copy the workloads/103-core-azure-update-manager files to your local ALZ-Bicep\workloads folder. We keep custom modules in a separate **workloads** folder so as not to cause any conflicts with upgrading of the ALZ-Bicep files.

The aumAccelerator uses several Bicep modules from the ALZ-Bicep repo. The **policyAssignmentManagementGroup.bicep** module to assign the *"Configure periodic checking for missing system updates on azure virtual machines"* policy definition to the Intermediate root management group. If you are not familar with policy assignment in Azure Landing zones, I recommend you visit the [Azure Enterprise Scale Landing Zone (ESLZ)](https://github.com/Azure/Enterprise-Scale/wiki/ALZ-Policies) architecture documentation before continuing.

### Azure Verified Modules (AVM)
Azure Verified Modules (AVM) is an initiative to consolidate and set the standards for what a good Infrastructure-as-Code module looks like.

Modules will then align to these standards, across languages (Bicep, Terraform etc.) and will then be classified as AVMs and available from their respective language specific registries.

AVM is a common code base, a toolkit for our Customers, our Partners, and Microsoft. It’s an official, Microsoft driven initiative, with a devolved ownership approach to develop modules, leveraging internal & external communities.

Azure Verified Modules enable and accelerate consistent solution development and delivery of cloud-native or migrated applications and their supporting infrastructure by codifying Microsoft guidance (WAF), with best practice configurations.

## Accelerator Modules
1. **policyAssignmentManagementGroup.bicep** - Assigns the *"Configure periodic checking for missing system updates on azure virtual machines"* policy definition to the Intermediate root management group. This module comes from the ALZ-Bicep repo.
2. **resourceGroup.bicep** - Creates the Azure resource group in the specified subscription for accelerator resources. This module comes from the ALZ-Bicep repo. (This has been replaced by an Azure Verified module in the main.bicep template.)
3. **maintenanceConfiguration.all.bicep** - This module will loop through all subscription objects defined in an array in the Bicep parameters file and create the maintenance configurations for the specified subscription. This is a custom accelerator module.
4. **managedIdentity.bicep** - Creates the Azure managed identity which will be assigned with "Log Analytics Reader" role for the specified subscription. This is a custom accelerator module.
5. **managedIdentityRoleAssignmentSubscription.bicep** - Assigns the *"Log Analytics Reader"* role to the Azure managed identity for the specified subscriptions. This role assignment is required in order for the alerts to function. This is a custom accelerator module.
6. **alertProcessingRule.bicep** - Creates the Azure alert processing rule for the specified subscription. Also creates an Action group.
7. **scheduledQueryRule.bicep** - Creates the Azure scheduled query rules for the specified subscription. This module is called multiple times to create the different update alerts already available in the Azure Update Manager solution. Alerts are: PendingUpdates, AssessmentFailures, and InstallationFailures.

## Pipelines
An Azure DevOps pipeline is available in the workloads/103-core-azure-update-manager/pipelines folder.

## Subscriptions array in Bicep parameters file (Bicepparm)
Deployment is meant to be by subscription, for each subscription you need Azure Update Manager deployed, duplicate the first subscription object, paste and update per subscription.

## Local Deployment
A Powershell script is provided to deploy the accelerator without using a pipeline. It is located in the workloads/lab folder. 

```
$Location = 'centralus'

#Lab
$TenantId = '00000000-0000-0000-0000-123456789098'
$ManagementGroupPrefix = 'alz'

Connect-AzAccount -TenantId $tenantId

# Create resources in each subscription, distributed.
New-AzManagementGroupDeployment -Name "alz-aumAccelerator-$Location" `
  -TemplateFile "workloads/103-core-azure-update-manager/main.bicep" `
  -TemplateParameterFile "workloads/103-core-azure-update-manager/main.bicepparam" `
  -ManagementGroupId $ManagementGroupPrefix `
  -Location $Location -verbose 

```
