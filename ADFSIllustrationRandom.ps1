<#
    Put the license here.
#>
<#
    To use this file you will need to set the file filter so that the script can pick up the images that you want to display as your Illustration
    in the ADFS login page. If you specify nothing,then everything will be picked up. Including this ps1 file, which is obviously not an image.
    This is simply calling the get-childitem cmdlet and appending whatever is in the file filter to the end of the path. 

    .Using a CSV File:
    The CSV File can be used to specify folders where you might have themed backgrounds. For example: if you have Christmas themed backgrounds and want
    to show them between Nov and Dec and Easter themed backgrounds or, <insert country> day, what ever. You can specify as many folders as you like, 
    you can even specify folders that have overlapping date ranges. If you do have folders that overlap, one folder is chosen at random.

    .Not Using a CSV File:
    The script will try and load the specified file, if it fails to find the file, or the file was never specified, it will just use
    its default behaviour which is to look for images according to the FileFilter in the running directory of the script. 
#>

#params
$FileFilter = "ADFS-*.png"
$CSVFile = ".\Folders.csv" 


# Dont Edit Below This Line.
#-----------------------------------------------------------------------------------------------------------
try
{
    $BaseFolders = Import-Csv $CSVFile
}
catch [System.IO.FileNotFoundException],[System.Management.Automation.ParameterBindingException]
{
    $Error.clear()
    #Enables the default behaviour if  a CSV file is not found.
    #The two types of errors that will get caught here are thrown when the path is not specified or the csv file is not found.
}

if($BaseFolders.count -ge 1){
    $BaseFolders | ForEach-Object{
        #DateConversion
        try
        {
            $_.StartDate = [datetime]::Parse($($_.StartDate))
        }
        catch [System.FormatException]
        {
            throw [System.FormatException] "$($_.FolderPath) StartDate is not formatted correctly"
        }
        try
        {
            $_.EndDate = [datetime]::Parse($($_.EndDate))
        }
        catch [System.FormatException]
        {
            throw [System.FormatException] "$($_.FolderPath) EndDate is not formatted correctly"
        }
        if(($_.StartDate.CompareTo($($_.EndDate))) -gt 0 )
        {
            throw "$($_.FolderPath) EndDate Cannot be earlier than StartDate"
        }
    }
    $CurrentDate = Get-Date
    $BaseFolders = $BaseFolders | where {$_.StartDate -LE $CurrentDate -and $_.EndDate -GE $CurrentDate}
    #If there are more than one folders returned after filtered within the date range; then pick one at random and pass it on.
    if($($BaseFolders.count) -gt 1)
    {
        $BaseFolders = $BaseFolders | Get-Random -Count 1
    }
}

#if no folders, use the script operating folder.
else
{
    $BaseFolders = [PSCustomObject]@{FolderPath = "."}
}


#By now there should only be one folder.
$BaseFolders.FolderPath = $BaseFolders.FolderPath + "\$FileFilter"

$files = get-childitem -Path $($BaseFolders.FolderPath)
$sample = $files | Get-Random -Count 1

Set-AdfsWebTheme -TargetName default -Illustration @{path=$sample.FullName} -Verbose