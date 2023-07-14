#set of all the commands that need to be done in order to deploy 

#INIT
$ENVIRONMENT= "PRD"
$PROPERTIES_FILE_NAME = "C:\Users\francesco.scandale\Desktop\WebMethodsPackages\devops-prod.properties"
$REPO = "WebMethodsPackages"

#From the .properties file
$COUNTRY = "MI"
$TYPEBUILD = "full"
$date = Get-Date -UFormat '%Y%m%d%H%M'

#cicd step
$CICD_IDENTIFIER = $COUNTRY + "_" + $ENVIRONMENT + "_" + $TYPEBUILD + "_" + $date

#NEXT LINES ARE ADDED BY ME
$PROPERTIES = ConvertFrom-StringData (Get-Content -Raw "$PROPERTIES_FILE_NAME")
$DeployerUser="Administrator" #this needs to be checked
$DeployerPwd="manage" #this needs to be checked



#BUILD
#clean
$BuildOutputDir = $PROPERTIES["build.output"]+"\$ENVIRONMENT"
$BuildSourceDir = $PROPERTIES["build.source"]+"\$ENVIRONMENT"
if (Test-Path $BuildOutputDir\*) {
  #Get-ChildItem -Path $BuildOutputDir -Recurse -Force | Remove-Item -Recurse -Force
  Set-Location $BuildOutputDir
  Remove-Item -Recurse -Force *
}
if (Test-Path $BuildSourceDir\*) {
  #Get-ChildItem -Path $BuildSourceDir -Recurse -Force | Remove-Item -Recurse -Force
  Set-Location $BuildSourceDir
  Remove-Item -Recurse -Force *
}

#preconditions
if($ENVIRONMENT -ne “PRD”){
	Write-Output "$ENVIRONMENT error - environment not valid"
	Throw Exception
}

$BuildScript = $PROPERTIES["build.script"]
$Log = "$BuildOutputDir\$CICD_IDENTIFIER.log"

Write-Output "--COPY SOURCE INTO 'BUILD SOURCE DIRECTORY'--"
Set-Location $BuildSourceDir
#git clone -b main --single-branch https://FrancescoScandale@github.com/FrancescoScandale/$REPO.git
git clone https://FrancescoScandale@github.com/FrancescoScandale/$REPO.git
if (!(Test-Path "$BuildSourceDir\$REPO\config")) {
  Write-Output "creating $REPO\config"
  New-Item -Path "$BuildSourceDir\$REPO\config" -ItemType Directory -Force
  $BuildConfigPath = $PROPERTIES["build.config.path"]
  $BuildConfigFiles = $PROPERTIES["build.config.files"]
  $SplitBuildConfigFiles = $BuildConfigFiles -split ","
  foreach ($file in $SplitBuildConfigFiles) {
    Copy-Item "$BuildConfigPath\$file" -Destination "$BuildSourceDir\$REPO\config"
    Write-Output "Copying file -> $file"
  }
  #Copy-Item "C:\SoftwareAG\IS\common" -Destination "$BuildSourceDir\$REPO\config" -Recurse
  #Copy-Item "C:\SoftwareAG\IS\jvm" -Destination "$BuildSourceDir\$REPO\config" -Recurse
  #Copy-Item "C:\SoftwareAG\IS\IntegrationServer\config\jdbc" -Destination "$BuildSourceDir\$REPO\config" -Recurse
} else {
  Throw "ERROR: configuration files folder already exists. Check the repository."
}
#CHECKS ... from row 163 to 222 (end of step)
Write-Output "--CHECK 'BAT SCRIPT' VARIABLE--"
if (-Not (Test-Path "$BuildScript")) {
  Write-Output "Error: 'build.bat' script doesn't exist"
  Throw "'build.bat' script doesn't exist"
}
Write-Output "--CHECK 'OUTPUT DIRECTORY' VARIABLE--"
if (-Not (Test-Path $BuildOutputDir)) {
  Write-Output "Error: The output directory doesn't exist"
  Throw "The output directory doesn't exist"
}
Write-Output "--CHECK 'SOURCE DIRECTORY' VARIABLE--"
if (-Not (Test-Path $BuildSourceDir)) {
  Write-Output "Error: The source directory doesn't exist"
  Throw "The source directory doesn't exist"
}
#END OF CHECKS
$BuildSourceDir2="$BuildSourceDir\$REPO" #SOURCE_DIR

#fbuild
cmd.exe /c "$BuildScript -Dbuild.output.dir=$BuildOutputDir -Dbuild.source.dir=$BuildSourceDir2 -Dbuild.log.fileName=$Log"

#archive artifacts
#here the github action saves the logs and the compiled packages, using upload-artifact

#COMPLETE COMMAND STRING
#C:\SoftwareAG\IS\common\AssetBuildEnvironment\bin\build.bat -Dbuild.output.dir="C:\SoftwareAG\DeployerFiles\Builds\MI\PRD" -Dbuild.source.dir="C:\SoftwareAG\DeployerFiles\BuildsRepo\git\MI\PRD\WebMethodsPackages" -Dbuild.log.filename="C:\SoftwareAG\DeployerFiles\Builds\MI\PRD\testBUILD.log"