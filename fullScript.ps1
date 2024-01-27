#!pwsh
#SCRIPT TO BUILD A FULL RELEASE 

#INIT
$PROPERTIES_FILE_NAME = "devops.properties"
$PROPERTIES = ConvertFrom-StringData (Get-Content -Raw "$PROPERTIES_FILE_NAME")
$ENVIRONMENT= $PROPERTIES["environment"]
$REPO = $PROPERTIES["repository"]
$COUNTRY = $REPO -split "-"
$COUNTRY = $COUNTRY[1]
$date = Get-Date -UFormat '%Y%m%d%H'
$CICD_IDENTIFIER = $COUNTRY + "_" + $ENVIRONMENT + "_" + $date

#BUILD - PREPARATION
#clean
$BuildOutputDir = $PROPERTIES["build.output"]+"\$ENVIRONMENT"
$BuildSourceDir = $PROPERTIES["build.source"]+"\$ENVIRONMENT"
if (Test-Path $BuildOutputDir\*) {
  Set-Location $BuildOutputDir
  Remove-Item -Recurse -Force *
}
if (Test-Path $BuildSourceDir\*) {
  Set-Location $BuildSourceDir
  Remove-Item -Recurse -Force *
}

Write-Output "BUILD STAGE"
if($ENVIRONMENT -ne “PRD”){
	Write-Output "$ENVIRONMENT error - environment not valid"
	Throw Exception
}
#arguments
$BuildScript = $PROPERTIES["build.script"]
$Log = "$BuildOutputDir\$CICD_IDENTIFIER.log"
#clone repo
Write-Output "--COPY SOURCE INTO 'BUILD SOURCE DIRECTORY'--"
Set-Location $BuildSourceDir
git clone https://github.com/FrancescoScandale/$REPO.git
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
#CHECKS
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
$BuildSourceDir2="$BuildSourceDir\$REPO"

#BUILD
cmd.exe /c "$BuildScript -Dbuild.output.dir=$BuildOutputDir -Dbuild.source.dir=$BuildSourceDir2 -Dbuild.log.fileName=$Log"



#DEPLOY - PREPARATION
Write-Output "DEPLOY STAGE"
#project automator
$DeployPathConfig = $PROPERTIES["deploy.config"] + "\$ENVIRONMENT"
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
#CHECKS
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
#deployer arguments
$ConfigFile = "$DeployPathConfig\config.properties"
$ConfigProperties = ConvertFrom-StringData (Get-Content -Raw "$ConfigFile")
$Candidate = $ConfigProperties["candidate.name"]
$Project = $ConfigProperties["project.name"]
$DeployerHost = $ConfigProperties["local.host"]
$DeployerPort = $ConfigProperties["local.port"]
$DeployerUser = $ConfigProperties["local.user"]
$DeployerPwd = $ConfigProperties["local.pwd"]
#CHECKS
Write-Output "PROPERTIES CHECK"
Write-Output "-----------------"
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
if ($DeployerHost -eq '') {
  Write-Output "Error: The 'local.host' property is blank."
  Throw "The 'local.host' property is blank"
}
Write-Output "---PORT---"
if ($DeployerPort -eq '') {
  Write-Output "Error: The 'local.port' property is blank."
  Throw "The 'local.port' property is blank"
}
Write-Output "---USER---"
if ($DeployerUser -eq '') {
  Write-Output "Error: The 'local.user' property is blank."
  Throw "The 'local.user' property is blank"
}
Write-Output "---PWD---"
if ($DeployerPwd -eq '') {
  Write-Output "Error: The 'local.pwd' property is blank."
  Throw "The 'local.pwd' property is blank"
}
Write-Output "-----------------"
#END OF CHECKS

#PROJECT AUTOMATOR
#update deployment_projectautomator
cmd.exe /c "$AntBat -f $UpdateAutomator"
#deployment objects creation
cmd.exe /c "$ProjectBat $ProjectAutomator $aLog"

#DEPLOY
cmd.exe /c "$DeployerBat --deploy -dc $Candidate -project $Project -host $DeployerHost -port $DeployerPort -user $DeployerUser -pwd $DeployerPwd $dLog"



#CLEANUP
#clean
Write-Output "CLEANUP STAGE"
if (Test-Path $BuildOutputDir\*) {
  Set-Location $BuildOutputDir
  Remove-Item -Recurse -Force *
}
if (Test-Path $BuildSourceDir\*) {
  Set-Location $BuildSourceDir
  Remove-Item -Recurse -Force *
}