#!pwsh
#SCRIPT TO CLEAN A FULL RELEASE

#INIT
$ENVIRONMENT= "PRD"
$PROPERTIES_FILE_NAME = "C:\Users\francesco.scandale\Desktop\WebMethodsPackages\devops-prod.properties"
$PROPERTIES = ConvertFrom-StringData (Get-Content -Raw "$PROPERTIES_FILE_NAME")

#CLEAN
$BuildOutputDir = $PROPERTIES["build.output"]+"\$ENVIRONMENT"
$BuildSourceDir = $PROPERTIES["build.source"]+"\$ENVIRONMENT"
Write-Output "CLEANUP STAGE"
if (Test-Path $BuildOutputDir\*) {
  Set-Location $BuildOutputDir
  Remove-Item -Recurse -Force *
}
if (Test-Path $BuildSourceDir\*) {
  Set-Location $BuildSourceDir
  Remove-Item -Recurse -Force *
}