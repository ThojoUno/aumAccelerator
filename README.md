# Azure Update Manager Accelerator (aumAccelerator)
The Azure Update Manager Accelerator (aumAccelerator) is a set of Azure Bicep templates for implementing all the Azure policies, maintenance configurations, alert rules, action groups, and alert processing rules required to manage software updates of Windows virtual machines in Azure, or Azure Arc-enabled virtual machines on-premise at scale. [Azure Update Manager](https://learn.microsoft.com/en-us/azure/update-manager/overview?tabs=azure-vms) is replacing Azure Update Management with Azure Automation, which is [retiring August 2024](https://azure.microsoft.com/en-us/updates/were-retiring-the-log-analytics-agent-in-azure-monitor-on-31-august-2024/).

This accelerator is designed to be deployed in an Azure Landing Zone (ALZ) environment on a per-subscription basis. This allows for different configurations based on application subscriptions, production subscriptions and other non-production subscriptions. For non-production subscriptions, you can scheduled the deployment of software updates based on Patch Tuesday, which is the 2nd Tuesday of the month. Then schedule virtual machine resources separately for production subscriptions. This allows you to test software updates in non-production environments before deploying to production environments.

This accelerator also deploys a separate maintenance configuration that will deploy Microsoft anti-malware (Defender) definitions on an hourly, or daily basis.

Alerts are configured to notify you when software updates are available, and when software updates are installed. Alerts are also configured to notify you if a patch assessment or software update deployment has failed. Alert severity is configurable. Pre-warning, alerting is still a work in progress, but the basics are included.

## Prerequisites
The aumAccelerator uses a number of Bicep modules from the [ALZ-Bicep](https://github.com/Azure/ALZ-Bicep/) Github repository, and from the [Common Azure Resource Modules Library (CARML)](https://github.com/Azure/ResourceModules) Github repository.

### ALZ-Bicep
I recommend you start with the [ALZ-Bicep accelerator](https://github.com/Azure/ALZ-Bicep/wiki/Accelerator), which will give you the basic framework for successfully implementing the aumAccelerator. After you complete the steps to implement the ALL-Bicep accelerator, copy the aumAccelerator files to your local ALZ-Bicep\config\custom-modules folder.

The aumAccelerator uses several Bicep modules from the ALZ-Bicep repo. The **resourceGroup.bicep** module for creating Azure resource groups, and the **policyAssignmentManagementGroup.bicep** module to assign the *"Configure periodic checking for missing system updates on azure virtual machines"* policy definition to the Intermediate root management group. If you are not familar with policy assignment in Azure Landing zones, I recommend you visit the [Azure Enterprise Scale Landing Zone (ESLZ)](https://github.com/Azure/Enterprise-Scale/wiki/ALZ-Policies) architecture documentation before continuing.

### Common Azure Resource Modules Library (CARML)
The CARML Github repo includes a library of mature and curated Bicep modules as well as a Continuous Integration (CI) environment leveraged for modules' validation and versioned publishing. The aumAccelerator uses the /authorization/policy-assignment/main.bicep module to assign Azure maintenance configurations. I simply download the CARML repo zip file, open and copy the modules/authorization folder to your local ALZ-Bicep\CARML\modules\authorization folder. This folder structure will not exist, so by copying the files, you will create it. There are a number of useful modules in the authorization folder. Consult the README.MD located in each sub-folder for usage information.

## Deployment order
The aumAccelerator is designed to be deployed in the following order via the "main" template:
1. **policyAssignmentManagementGroup.bicep** - Assigns the *"Configure periodic checking for missing system updates on azure virtual machines"* policy definition to the Intermediate root management group. This module comes from the ALZ-Bicep repo.
2. **resourceGroup.bicep** - Creates the Azure resource group in the specified subscription for accelerator resources. This module comes from the ALZ-Bicep repo.
3. **maintenance-configurations-all.aum.bicep** - Creates the Azure maintenance configurations for the specified subscription. This is a custom accelerator module.
4. **managed-identity.aum.bicep** - Creates the Azure managed identity which will be assigned with "Log Analytics Reader" role for the specified subscription. This is a custom accelerator module.
5. **managed-identity-role-assignment.aum.bicep** - Assigns the *"Log Analytics Reader"* role to the Azure managed identity for the specified subscriptions. This role assignment is required in order for the alerts to function. This is a custom accelerator module.
6. **action-group.aum.bicep** - Creates the Azure action group for the specified subscription.
7. **scheduled-query-rule.aum.bicep** - Creates the Azure scheduled query rules for the specified subscription. This module is called multiple times to create the different update alerts already available in the Azure Update Manager solution. Alerts are: PendingUpdates, AssessmentFailures, and InstallationFailures.
8. **alert-processing-rules.aum.bicep** - Creates the Azure alert processing rule for the specified subscription.
