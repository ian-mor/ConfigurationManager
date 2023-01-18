<#

2023-01-18
ian-mor

Sample script to query Microsoft Endpoint Configuration Manager (formerly SCCM) for the deployment status of Windows Updates to a collection.

#>

# Function to convert StatusType integer to description
Function Get-CmStatusType ($statusNumber) {
    
    switch ($statusNumber) {
        1 {$getStatusDesc = "Success"}
        2 {$getStatusDesc = "InProgress"}
        4 {$getStatusDesc = "Unknown"}
        5 {$getStatusDesc = "Error"}
        Default {$getStatusDesc = $statusNumber}
    }

    return $getStatusDesc
}

# Connect to ConfigurationManager - Requires Console to be installed
# Refer to Getting Started article for more information how to configure the module
# https://learn.microsoft.com/en-us/powershell/sccm/overview?view=sccm-ps
Import-Module "C:\Program Files (x86)\ConfigMgr\bin\ConfigurationManager.psd1"
Update-FormatData "mecmFormats.ps1xml"
Set-Location CB1:

# Targeted Collection & Software Name
$collectionName = "MSU - Application - Dev"
$wsuSoftwareName = "Windows Server Updates 2023-01"

# Get Per-Server Deployment Details by Collection Name
$deploymentDetails = Get-CMDeployment -CollectionName $collectionName -SoftwareName $wsuSoftwareName
$suAssignment = Get-CMSoftwareUpdateDeployment -DeploymentId $deploymentDetails.DeploymentID
$suDeploymentSummary = Get-CMSoftwareUpdateDeploymentStatus -InputObject $suAssignment
$deploymentStatusDetails = Get-CMDeploymentStatusDetails -InputObject $suDeploymentSummary[0]
$deploymentStatusDetails | Select-Object DeviceName, IsCompliant, StatusTime, @{expression = {Get-CmStatusType $_.StatusType}; label="StatusType"}, StatusDescription, AssignmentName | Format-Table


