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
docker save -o ".\mosquitto-hc-$TAG.tar" "mosquitto-hc:$TAG"
