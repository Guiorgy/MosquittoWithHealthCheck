param(
  [Parameter(Mandatory=$true)]
  [string] # Comma-separated list of versions
  $Versions
)

# This script uses docker buildx. To create and enable buildx execute the following commands:
#   docker buildx create --name mosquitto-hc
#   docker buildx use mosquitto-hc

# Build the exact version tag only
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

# Build the exact version tag as well as latest, major.minor and major tags
function Build-All {
  param(
    [Parameter(Mandatory = $true)]
    [version]
    $Version
  )

  $MajorMinor = "$($Version.Major).$($Version.Minor)"
  $Major = "$($Version.Major)"

  Write-Host "Building latest, $Version, $MajorMinor and $Major based on $Version"
  docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm64/v8 -t "guiorgy/mosquitto-hc:latest" -t "guiorgy/mosquitto-hc:$Version" -t "guiorgy/mosquitto-hc:$MajorMinor" -t "guiorgy/mosquitto-hc:$Major" --build-arg TAG="$Version" --push .

  Write-Host "Building openssl, $Version-openssl, $MajorMinor-openssl and $Major-openssl based on $Version-openssl"
  docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm64/v8 -t "guiorgy/mosquitto-hc:openssl" -t "guiorgy/mosquitto-hc:$Version-openssl" -t "guiorgy/mosquitto-hc:$MajorMinor-openssl" -t "guiorgy/mosquitto-hc:$Major-openssl" --build-arg TAG="$Version-openssl" --push .
}

# Separate the versions, convert them to [version] objects, and sort them
$VersionsSorted = $Versions -split ',' | ForEach-Object { [version]$_ } | Sort-Object

# Separate the old and the latest version
$OldVersions = $VersionsSorted[0..($VersionsSorted.Count - 2)]
$LatestVersion = $VersionsSorted[-1]

foreach ($Version in $OldVersions) {
  Build-Version $Version
}

Build-All $LatestVersion
