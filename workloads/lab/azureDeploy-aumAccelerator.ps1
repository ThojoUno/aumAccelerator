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




