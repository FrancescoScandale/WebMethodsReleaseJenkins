#set of all the commands that need to be done in order to deploy 

#INIT
$ENVIRONMENT= "PRD"
$PROPERTIES_FILE_NAME = "C:\Users\francesco.scandale\OneDrive - Accenture\Desktop\CICD-Thesis\devops-prod.properties"
$REPO = "Symphony-Webmethods-EMEA-ES"

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
  Get-ChildItem -Path $BuildOutputDir -Recurse -Force | Remove-Item -Recurse -Force
}
if (Test-Path $BuildSourceDir\*) {
  Get-ChildItem -Path $BuildSourceDir -Recurse -Force | Remove-Item -Recurse -Force
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
git clone -b main --single-branch https://github.com/Amplifon-Organization/$REPO.git
if (!(Test-Path "$BuildSourceDir\$REPO\config")) {
  New-Item -Path "$BuildSourceDir\$REPO\config" -ItemType Directory -Force
  $BuildConfigPath = $PROPERTIES["build.config.path"]
  $BuildConfigFiles = $PROPERTIES["build.config.files"]
  $SplitBuildConfigFiles = $BuildConfigFiles -split ","
  foreach ($file in $SplitBuildConfigFiles) {
    Copy-Item "$BuildConfigPath\$file" -Destination "$BuildSourceDir\$REPO\config"
  }
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
$BuildSourceDir2="$BuildSourceDir\$Repo" #SOURCE_DIR

#fbuild
cmd.exe /c "$BuildScript -Dbuild.output.dir=$BuildOutputDir -Dbuild.source.dir=$BuildSourceDir2 -Dbuild.log.fileName=$Log"

#archive artifacts
#here the github action saves the logs and the compiled packages, using upload-artifact



#DEPLOY
#dpreconditions
$DeployPathConfig = $PROPERTIES["deploy.config"] + "\$ENVIRONMENT" #path_config
$UpdateAutomator = $PROPERTIES["deploy.update.automator"]
$UpdateAutomator = $UpdateAutomator.replace('{{_COUNTRY_}}', "$COUNTRY")
$UpdateAutomator = $UpdateAutomator.replace('{{_ENV_}}', "$ENVIRONMENT")
$ProjectAutomator = "$DeployPathConfig\Deployment_ProjectAutomator.xml"
$AntBat = $PROPERTIES["deploy.ant.script"]
$DeployPath = $PROPERTIES["deploy.path"]
$ProjectBat = "$DeployPath\projectautomator.bat"
$DeployerBat = "$DeployPath\Deployer.bat"
$aLog = "$DeployPathConfig\logs\automator_$CICD_IDENTIFIER.log"
$dLog = "$DeployPathConfig\logs\deploy_$CICD_IDENTIFIER.log"
#CHECKS ... from row 420 to 453 (end of step) ...
Write-Output "--CHECK 'ANT BAT SCRIPT' VARIABLE--"
if (-Not (Test-Path -Path $AntBat)) {
  Write-Output "Error: file $AntBat does NOT exist."
  Throw "file $AntBat does NOT exist"
}
Write-Output "--CHECK 'UPDATE AUTOMATOR XML FILE' VARIABLE--"
if (-not (Test-Path -Path $UpdateAutomator)) {
  Write-Output "Error: file $UpdateAutomator does NOT exist."
  Throw "file $UpdateAutomator does NOT exist"
}
Write-Output "--CHECK 'PROJECT BAT SCRIPT' VARIABLE--"
if (-not (Test-Path -Path $ProjectBat)) {
  Write-Output "Error: file $ProjectBat does NOT exist."
  Throw "file $ProjectBat does NOT exist"
}
Write-Output "--CHECK 'PROJECT XML FILE' VARIABLE--"
if (-not (Test-Path -Path $ProjectAutomator)) {
  Write-Output "Error: file $ProjectAutomator does NOT exist."
  Throw "file $ProjectAutomator does NOT exist"
}
Write-Output "--CHECK 'DEPLOYER BAT SCRIPT' VARIABLE--"
if (-not (Test-Path -Path $DeployerBat)) {
  Write-Output "Error: file $DeployerBat does NOT exist."
  Throw "file $DeployerBat does NOT exist"
}
#END OF CHECKS
$ConfigProperties = "$DeployPathConfig\config.properties" #PROP_FILE
$CDKeyvalue = Select-String -Path $ConfigProperties -pattern "candidate.name" -CaseSensitive
$CDValue = $CDKeyvalue-split "="
$Candidate = $CDValue[1].Trim()
$ProjectKeyvalue = Select-String -Path $ConfigProperties -pattern "project.name" -CaseSensitive
$ProjectValue = $ProjectKeyvalue -split "="
$Project = $ProjectValue[1].Trim()
$HostKeyvalue = Select-String -Path $ConfigProperties -pattern "local.host" -CaseSensitive
$HostValue = $HostKeyvalue -split "="
$Host0 = $HostValue[1].Trim()
$PortKeyvalue = Select-String -Path $ConfigProperties -pattern "local.port" -CaseSensitive
$PortValue = $PortKeyvalue -split "="
$Port0 = $PortValue[1].Trim()
#CHECKS ... from row 454 to 498 (end of step) ...
Write-Output "PROPERTIES CHECK"
Write-Output "-----------------"
if (-not (Test-Path -Path $ConfigProperties)) {
  Write-Output "Error: The file '$ConfigProperties' does NOT exist."
  Throw "The file '$ConfigProperties' does NOT exist"
}
Write-Output "---CANDIDATE NAME---"
if ($Candidate -eq '') {
  Write-Output "Error: The 'candidate.name' property is blank."
  Throw "The 'candidate.name' property is blank"
}
Write-Output "---PROJECT NAME---"
if ($Project -eq '') {
  Write-Output "Error: The 'project.name' property is blank."
  Throw "The 'project.name' property is blank"
}
Write-Output "---HOST---"
if ($Host0 -eq '') {
  Write-Output "Error: The 'local.host' property is blank."
  Throw "The 'local.host' property is blank"
}
Write-Output "---PORT---"
if ($Port0 -eq '') {
  Write-Output "Error: The 'local.port' property is blank."
  Throw "The 'local.port' property is blank"
}
Write-Output "-----------------"
#END OF CHECKS

#update deployment_projectautomator
cmd.exe /c "$AntBat -f $UpdateAutomator"

#deployment objects creation
cmd.exe /c "$ProjectBat $ProjectAutomator $aLog"

#packages deploy
cmd.exe /c "$DeployerBat --deploy -dc $Candidate -project $Project -host $Host0 -port $Port0 -user $DeployerUser -pwd $DeployerPwd $dLog"

#archive artifacts
#here the github action saves the logs, using upload-artifact



#CLEANUP
#clean
if (Test-Path $BuildOutputDir\*) {
    Get-ChildItem -Path $BuildOutputDir -Recurse -Force | Remove-Item -Recurse -Force
  }
  if (Test-Path $BuildSourceDir\*) {
    Get-ChildItem -Path $BuildSourceDir -Recurse -Force | Remove-Item -Recurse -Force
  }