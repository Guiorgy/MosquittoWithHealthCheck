param(
  [Parameter(Mandatory = $true)]
  [object] # Comma-separated list of versions
  $Versions,

  [Parameter(Mandatory = $false)]
  [Alias('WhatIf')]
  [switch]
  $DryRun
)

# This script uses docker buildx. To create and enable buildx execute the following commands:
#   docker buildx create --name mosquitto-hc
#   docker buildx use mosquitto-hc

# Conditionally execute or print the command and its arguments in dry-run
function Run {
  [CmdletBinding()]
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]]$AllArgs
  )

  if (-not $AllArgs -or $AllArgs.Count -eq 0) { return }

  $startIndex = 0
  $exitOnDryRun = $false
  while ($startIndex -lt $AllArgs.Count -and $AllArgs[$startIndex] -is [string] -and $AllArgs[$startIndex].StartsWith('-')) {
    $flag = $AllArgs[$startIndex]

    switch ($flag) {
      '-ExitOnDryRun' {
        $exitOnDryRun = $true
        $startIndex++
      }
      default {
        throw "Invalid argument for 'Run': '$flag'"
      }
    }
  }

  if ($startIndex -ge $AllArgs.Count) { return }

  # Extract the command and its remaining arguments
  $Command = $AllArgs[$startIndex]
  $CommandArgs = if ($AllArgs.Count -gt ($startIndex + 1)) { 
    $AllArgs[($startIndex + 1)..$AllArgs.GetUpperBound(0)] 
  } else { 
    @() 
  }

  if ($DryRun) {
    Write-Host "[DRY RUN] Would run: $Command $($CommandArgs -join ' ')" -ForegroundColor Yellow
    
    if ($exitOnDryRun) {
      Write-Host '[DRY RUN] Terminating script' -ForegroundColor DarkYellow
      exit 0
    }
  } 
  else {
    & $Command @CommandArgs
  }
}

# Terminate if the version is outside the supported range
function Assert-VersionSupported {
  param(
    [Parameter(Mandatory = $true)]
    [version]
    $Version,

    [Parameter(Mandatory = $true)]
    [version]
    $MinimumVersion,

    [Parameter(Mandatory = $true)]
    [version]
    $UpperBoundVersion
  )

  if ($MinimumVersion -ge $UpperBoundVersion) {
    throw "Invalid MinimumVersion and UpperBoundVersion for Assert-VersionSupported: '$MinimumVersion' must be less than '$UpperBoundVersion'"
  }

  if ($Version -lt $MinimumVersion -or $Version -ge $UpperBoundVersion) {
    throw "Unsupported version: '$Version' must be between '$MinimumVersion' and '$UpperBoundVersion'"
  }
}

# Build the exact version tag only
function Build-Version {
  param(
    [Parameter(Mandatory = $true)]
    [version]
    $Version
  )

  Write-Host "Building $Version-alpine based on $Version-alpine"
  Run docker buildx build --platform 'linux/amd64,linux/arm/v6,linux/arm64/v8' -t "guiorgy/mosquitto-hc:$Version-alpine" --build-arg TAG="$Version-alpine" --push .
}

# Build the exact version tag as well as latest, major.minor and major tags
function Build-All {
  param(
    [Parameter(Mandatory = $true)]
    [version]
    $Version
  )

  $MajorMinor = "$($Version.Major).$($Version.Minor)"
  $Major = "$($Version.Major)"

  Write-Host "Building latest, alpine, $Version-alpine, $MajorMinor-alpine and $Major based on $Version-alpine"
  Run docker buildx build --platform 'linux/amd64,linux/arm/v6,linux/arm64/v8' -t "guiorgy/mosquitto-hc:latest" -t "guiorgy/mosquitto-hc:alpine" -t "guiorgy/mosquitto-hc:$Version-alpine" -t "guiorgy/mosquitto-hc:$MajorMinor-alpine" -t "guiorgy/mosquitto-hc:$Major" --build-arg TAG="$Version-alpine" --push .
}

if ($Versions -is [string]) {
  # Separate the comma-separated versions
  $Versions = $Versions -split ',' | ForEach-Object { $_.Trim() }
}

if ($Versions -is [System.Collections.IEnumerable]) {
  # Convert version strings to [version] objects and sort them
  $VersionsSorted = $Versions | ForEach-Object { [version]$_ } | Sort-Object
} else {
  throw "Unexpected Version parameter type: '$($Versions.GetType())'"
}

# Separate the old and the latest version
$OldVersions = $VersionsSorted[0..($VersionsSorted.Count - 2)]
$LatestVersion = $VersionsSorted[-1]

# Supported version range
$MinimumVersion = '2.1.0'
$UpperBoundVersion = '2.2.0'

foreach ($Version in $OldVersions) {
  Assert-VersionSupported $Version $MinimumVersion $UpperBoundVersion
  Build-Version $Version
}

Assert-VersionSupported $LatestVersion $MinimumVersion $UpperBoundVersion
Build-All $LatestVersion
