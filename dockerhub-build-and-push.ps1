param(
  [Parameter(Mandatory=$true)]
  [string] # Comma-separated list of versions
  $VERSIONS
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

  Write-Host "Building $VERSION based on $VERSION"
  docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm64/v8 -t "guiorgy/mosquitto-hc:$VERSION" --build-arg TAG="$VERSION" --push .
  Write-Host "Building $VERSION-openssl based on $VERSION-openssl"
  docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm64/v8 -t "guiorgy/mosquitto-hc:$VERSION-openssl" --build-arg TAG="$VERSION-openssl" --push .
}

function Build-Latest {
  param(
    [Parameter(Mandatory = $true)]
    [version]
    $Version
  )

  Write-Host "Building latest based on $VERSION"
  docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm64/v8 -t "guiorgy/mosquitto-hc:latest" --build-arg TAG="$VERSION" --push .
  Write-Host "Building openssl based on $VERSION-openssl"
  docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm64/v8 -t "guiorgy/mosquitto-hc:openssl" --build-arg TAG="$VERSION-openssl" --push .
}

# Separate the versions, convert them to [version] objects, and sort them
$VERSIONS_SORTED = $VERSIONS -split ',' | ForEach-Object { [version]$_ } | Sort-Object

# Separate the old and the latest version
$OLD_VERSIONS = $VERSIONS_SORTED[0..($VERSIONS_SORTED.Count - 2)]
$LATEST_VERSION = $VERSIONS_SORTED[-1]

foreach ($VERSION in $OLD_VERSIONS) {
  Build-Version $VERSION
}

Build-Version $LATEST_VERSION
Build-Latest $LATEST_VERSION
