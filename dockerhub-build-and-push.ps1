param(
  [Parameter(Mandatory=$true)]
  [string] # Comma-separated list of versions
  $Versions
)

# This script uses docker buildx. To create and enable buildx execute the following commands:
#   docker buildx create --name mosquitto-hc
#   docker buildx use mosquitto-hc

function Build-Version {
  param(
    [Parameter(Mandatory = $true)]
    [version]
    $Version
  )

  Write-Host "Building $Version based on $Version"
  docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm64/v8 -t "guiorgy/mosquitto-hc:$Version" --build-arg TAG="$Version" --push .
  Write-Host "Building $Version-openssl based on $Version-openssl"
  docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm64/v8 -t "guiorgy/mosquitto-hc:$Version-openssl" --build-arg TAG="$Version-openssl" --push .
}

function Build-Latest {
  param(
    [Parameter(Mandatory = $true)]
    [version]
    $Version
  )

  Write-Host "Building latest based on $Version"
  docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm64/v8 -t "guiorgy/mosquitto-hc:latest" --build-arg TAG="$Version" --push .
  Write-Host "Building openssl based on $Version-openssl"
  docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm64/v8 -t "guiorgy/mosquitto-hc:openssl" --build-arg TAG="$Version-openssl" --push .
}

# Separate the versions, convert them to [version] objects, and sort them
$VersionsSorted = $Versions -split ',' | ForEach-Object { [version]$_ } | Sort-Object

# Separate the old and the latest version
$OldVersions = $VersionsSorted[0..($VersionsSorted.Count - 2)]
$LatestVersion = $VersionsSorted[-1]

foreach ($Version in $OldVersions) {
  Build-Version $Version
}

Build-Version $LatestVersion
Build-Latest $LatestVersion
