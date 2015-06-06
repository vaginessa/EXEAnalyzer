<#
.SYNOPSIS
    Extracts the contents within self-extracting archives, and searches the resulting files for keywords. 
.DESCRIPTION
	Using 7-zip the script will attempt to extract the files contained within a given self-extracting archive. The contents of these files can be valuable for static analysis and application assessments.
.NOTES
    File Name      : ExtractAndAnalyze.ps1
    Author         : Adam Greenhill (adam.greenhill@gmail.com)
    Prerequisite   : 7-zip
.LINK
    Script posted over:
    https://github.com/AdamGreenhill/Self-Extracting-Archive-Analyzer
.PARAMETER In
	The self-extracting archive
.PARAMETER Out
	Serves two functions: first is the destination of the extracted files, and second is the location used in the search
.PARAMETER SearchTerms
	Text file that contains search terms separated by newlines
.PARAMETER Path
	The full or relative path to 7-zip's executable
.PARAMETER OnlySearch
	Prevents the script from extracting any files
.PARAMETER Live
	Not yet implemented
.EXAMPLE
    ExtractAndAnalyze.ps1 -In ".\Self-extracting archive.exe" -Out ".\Output directory\" -SearchTerms ".\File containing search terms.txt" -Path "\Path\to\7-zip"
.EXAMPLE
    ExtractAndAnalyze.ps1 -OnlySearch -Out ".\Directory containing files to search\" -SearchTerms ".\File containing search terms.txt"
	
	Note: For searching directories, you do not need to provide a path to 7-zip or a self-extracting archive.
#>


Param(
  [string]$In,
  [string]$Out,
  [string]$SearchTerms,
  [string]$Path = "$env:ProgramFiles\7-Zip\7z.exe",
  [switch]$OnlySearch = $False,
  [switch]$Live = $False
)

# Hides Errors
$ErrorActionPreference = "silentlycontinue"

# Uses 7-zip to extract the contents within self-extracting archives to an output directory
If ($OnlySearch -eq $False ) {	
	If (Test-Path $In) {
		If (!(Test-Path $Path)) {
			Write-Host "`nCould not find 7-zip at '$Path'`n" -foregroundcolor "Red" -backgroundcolor "Black"
			Exit
		}
		Write-Host "`nStarting the extraction of '$In'" -foregroundcolor "Cyan" -backgroundcolor "Black"
		Get-ChildItem "$In" | % {& "$Path" "x" $_.fullname "-o$Out"}
		Write-Host "`nFinished extracting." -foregroundcolor "Cyan" -backgroundcolor "Black"
	} Else {
		Write-Host "`nCould not find the self-extracting archive at '$in'`n" -foregroundcolor "Red" -backgroundcolor "Black"
		Exit
	}
}
	
# Outputs files that contain the keyword
If ($Live -eq $False) {
	If (Test-Path $Out) {
		If (Test-Path $SearchTerms) {
			ForEach ( $Term In (Get-Content $SearchTerms) ) {
				Write-Host "`nSearch term: '$Term'" -foregroundcolor "Cyan" -backgroundcolor "Black"
				Get-ChildItem -Recurse "$Out" | Where-Object { Select-String "$Term" $_ -Quiet }
			}
		} Else {
			Write-Host "`nCould not find the search terms at '$SearchTerms'`n" -foregroundcolor "Red" -backgroundcolor "Black"
			Exit
		}
	} Else {
		Write-Host "`nCould not find the search directory at '$out'`n" -foregroundcolor "Red" -backgroundcolor "Black"
		Exit
	}
}