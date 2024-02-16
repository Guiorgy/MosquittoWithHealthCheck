param(
  [Parameter(Mandatory=$true)]
  [string]
  $VERSION
)

echo "Building images for $VERSION"

# docker buildx create --name mosquitto-hc
# docker buildx use mosquitto-hc
docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm64/v8 -t "guiorgy/mosquitto-hc:latest" --build-arg TAG="latest" --push .
docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm64/v8 -t "guiorgy/mosquitto-hc:$VERSION" --build-arg TAG="$VERSION" --push .
docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm64/v8 -t "guiorgy/mosquitto-hc:openssl" --build-arg TAG="openssl" --push .
docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm64/v8 -t "guiorgy/mosquitto-hc:$VERSION-openssl" --build-arg TAG="$VERSION-openssl" --push .
