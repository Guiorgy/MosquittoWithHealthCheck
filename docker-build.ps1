param(
  [Parameter(Mandatory=$false)]
  [string]
  $TAG
)

if (!$TAG) {
  $TAG = 'latest'
}

echo "Building image for $TAG"

docker build --build-arg TAG="$TAG" -t "mosquitto-hc:$TAG" -f Dockerfile .

if ($PSVersionTable.PSVersion.Major -ge 7) {
  docker save "mosquitto-hc:$TAG" | gzip --best --stdout --verbose > "./mosquitto-hc-$TAG.tar.gz"
} else {
  # PowerShell 5 doesn't handle byte streams properly resulting in a corrupted archive
  cmd /c "docker save mosquitto-hc:$TAG | gzip --best --stdout --verbose > ./mosquitto-hc-$TAG.tar.gz"
}
