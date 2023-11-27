$Location = 'westus2'

#Lab
$TenantId = '00000000-0000-0000-0000-123456789098'
$workloadfolder = 'workloads/lab'
$ManagementGroupPrefix = 'eslz'

Connect-AzAccount -TenantId $tenantId

# Create resources in each subscription, distributed.
New-AzManagementGroupDeployment -Name "alz-aumAccelerator-$Location" `
  -TemplateFile "config/custom-modules/main.aumAccelerator-sub.bicep" `
  -TemplateParameterFile "$workloadfolder/main.aumAccelerator-sub.bicepparam" `
  -ManagementGroupId $ManagementGroupPrefix `
  -Location $Location -verbose 




