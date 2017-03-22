[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation
try {
    # get task properties
    $paramSpUrl = Get-VstsInput -Name spUrl -Require
	$paramDocLibTitle = Get-VstsInput -Name docLibTitle -Require
	$paramLogin = Get-VstsInput -Name login -Require
	$paramPassword = Get-VstsInput -Name password -Require
	$paramFiles = Get-VstsInput -Name filesToUpload -Require

	# log properties to task output
    Write-Host "Site URL: $paramSpUrl"
	Write-Host "Document library: $paramDocLibTitle"
	Write-Host "Login $paramLogin"

	# load SharePoint CSOM assemblies
	Add-Type -Path Microsoft.SharePoint.Client.dll
	Add-Type -Path Microsoft.SharePoint.Client.Runtime.dll
	Add-Type -Path Microsoft.SharePoint.Client.UserProfiles.dll

	# prepare credentials to be used to connect to app catalog
	$securePassword = ConvertTo-SecureString $paramPassword -AsPlainText -Force 
	$creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($paramLogin, $securePassword)

	# init SP context
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($paramSpUrl)
	$ctx.Credentials = $creds

	# load app catalog library and root folder
	$targetLib = $ctx.Web.Lists.GetByTitle($paramDocLibTitle)
	$ctx.Load($targetLib)
	$ctx.Load($targetLib.RootFolder)
	$ctx.ExecuteQuery()

	# if 'filesToUpload' is folder path - append all files mask
	if ($paramFiles.LastIndexOf('/') -gt $paramFiles.LastIndexOf('.')) {
		$paramFiles = $paramFiles.TrimEnd('/')
		$paramFiles += '/**/*.*'
	}


	$filesToUpload = Get-ChildItem -Path $paramFiles -Recurse

	# upload files
	Foreach ($file in $filesToUpload)
	{
		Write-Host "Uploading '$file'..."

		$fileStream = New-Object IO.FileStream($file.FullName,[System.IO.FileMode]::Open)
		$fileURL = $targetLib.RootFolder.ServerRelativeUrl + "/" + $file.Name

		$fileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
		$fileCreationInfo.Overwrite = $true
		$fileCreationInfo.ContentStream = $fileStream
		$fileCreationInfo.URL = $fileURL

		$uploadedFile = $targetLib.RootFolder.Files.Add($fileCreationInfo)
		$uploadedFile.ListItemAllFields["Title"] = $file.Name;
		$uploadedFile.ListItemAllFields.Update();
		$ctx.ExecuteQuery();
		if ($uploadedFile.CheckOutType -ne [Microsoft.SharePoint.Client.CheckOutType].None) { 
			$uploadedFile.CheckIn("Uploaded from VSTS.", [Microsoft.SharePoint.Client.CheckinType].MajorCheckIn);
		}

		$ctx.ExecuteQuery()
	}

	Write-Host "Finished uploading files to document library '$paramDocLibTitle' at '$paramSpUrl'."
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
