# Azure Update Manager Accelerator (aumAccelerator)
The Azure Update Manager Accelerator (aumAccelerator) is a set of Azure Bicep templates for implementing all the Azure policies, maintenance configurations, alert rules, action groups, and alert processing rules required to manage software updates of Windows virtual machines in Azure, or Azure Arc-enabled virtual machines on-premise at scale. [Azure Update Manager](https://learn.microsoft.com/en-us/azure/update-manager/overview?tabs=azure-vms) is replacing Azure Update Management with Azure Automation, which is [retiring August 2024](https://azure.microsoft.com/en-us/updates/were-retiring-the-log-analytics-agent-in-azure-monitor-on-31-august-2024/).

## Prerequisites
The aumAccelerator uses a number of Bicep modules from the [ALZ-Bicep](https://github.com/Azure/ALZ-Bicep/) Github repository, and from the [Common Azure Resource Modules Library (CARML)](https://github.com/Azure/ResourceModules) Github repository.

### ALZ-Bicep
I recommend you start with the [ALZ-Bicep accelerator](https://github.com/Azure/ALZ-Bicep/wiki/Accelerator), which will give you the basic framework for successfully implementing the aumAccelerator. After you complete the steps to implement the ALL-Bicep accelerator, copy the aumAccelerator files to your local ALZ-Bicep\config\custom-modules folder.

The aumAccelerator uses several Bicep modules from the ALZ-Bicep repo. The **resourceGroup.bicep** module for creating Azure resource groups, and the **policyAssignmentManagementGroup.bicep** module to assign the *"Configure periodic checking for missing system updates on azure virtual machines"* policy definition to the Intermediate root management group. If you are not familar with policy assignment in Azure Landing zones, I recommend you visit the [Azure Enterprise Scale Landing Zone (ESLZ)](https://github.com/Azure/Enterprise-Scale/wiki/ALZ-Policies) architecture documentation before continuing.

### Common Azure Resource Modules Library (CARML)
The CARML Github repo includes a library of mature and curated Bicep modules as well as a Continuous Integration (CI) environment leveraged for modules' validation and versioned publishing. The aumAccelerator uses the /authorization/policy-assignment/main.bicep module to assign Azure maintenance configurations. I simply download the CARML repo zip file, open and copy the modules/authorization folder to your local ALZ-Bicep\CARML\modules\authorization folder. This folder structure will not exist, so by copying the files, you will create it. There are a number of useful modules in the authorization folder. Consult the README.MD located in each sub-folder for usage information.

