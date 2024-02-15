param(
  [Parameter(Mandatory=$false)]
  [string]
  $TAG
)

if (!$TAG) {
  $TAG = 'latest'
}

echo "Building image for $TAG"

# replace \r\n with \n
(Get-Content .\docker-entrypoint.sh -Raw).replace("`r`n", "`n") | Out-File -FilePath .\docker-entrypoint.sh
(Get-Content .\check-health.sh -Raw).replace("`r`n", "`n") | Out-File -FilePath .\check-health.sh

docker build --build-arg TAG="$TAG" -t "mosquitto-hc:$TAG" -f Dockerfile .
docker save -o ".\mosquitto-hc-$TAG.tar" "mosquitto-hc:$TAG"
