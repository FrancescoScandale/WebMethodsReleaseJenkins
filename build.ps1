#!pwsh
#SCRIPT TO BUILD A FULL RELEASE 

#INIT
$ENVIRONMENT= "PRD"
$PROPERTIES_FILE_NAME = "devops.properties"
$REPO = "WebMethodsPackages"

#From the .properties file
$COUNTRY = "MI"
$TYPEBUILD = "full"
$date = Get-Date -UFormat '%Y%m%d%H'

#cicd step
$CICD_IDENTIFIER = $COUNTRY + "_" + $ENVIRONMENT + "_" + $TYPEBUILD + "_" + $date

#useful variables
$PROPERTIES = ConvertFrom-StringData (Get-Content -Raw "$PROPERTIES_FILE_NAME")


#BUILD
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
#preconditions
if($ENVIRONMENT -ne “PRD”){
	Write-Output "$ENVIRONMENT error - environment not valid"
	Throw Exception
}

$BuildScript = $PROPERTIES["build.script"]
$Log = "$BuildOutputDir\$CICD_IDENTIFIER.log"

Write-Output "--COPY SOURCE INTO 'BUILD SOURCE DIRECTORY'--"
Set-Location $BuildSourceDir
git clone https://FrancescoScandale@github.com/FrancescoScandale/$REPO.git
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
$BuildSourceDir2="$BuildSourceDir\$REPO" #SOURCE_DIR

#fbuild
cmd.exe /c "$BuildScript -Dbuild.output.dir=$BuildOutputDir -Dbuild.source.dir=$BuildSourceDir2 -Dbuild.log.fileName=$Log"