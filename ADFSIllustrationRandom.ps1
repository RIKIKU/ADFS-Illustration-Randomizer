$files = dir -Path 'C:\ADFS Images\ADFS-*.png' -Recurse
$sample = $files | Get-Random -Count 1
Set-AdfsWebTheme -TargetName default -Illustration @{path=$sample.FullName} -Verbose