# Mosquitto Docker Image With Health Checks

Containers built with this Dockerfile pull the [Eclipse Mosquitto](https://github.com/eclipse/mosquitto/tree/master/docker) image and extend it by adding a heanthcheck test.

## Building

Run `docker-build.ps1` Powershell or `docker-build.sh` Bash script to build the latest image, or pass a specific tag (e.g. 2.0.18) to pull and buld that version. For example:

- Powershell

    ```powershell
    .\docker-build.ps1
    .\docker-build.ps1 latest
    .\docker-build.ps1 2.0.18
    ```

- Bash

    ```bash
    chmod +x ./docker-build.sh
    ./docker-build.sh
    ./docker-build.sh latest
    ./docker-build.sh 2.0.18
    ```

To build without using those scripts:

```bash
docker build --build-arg TAG=latest -t mosquitto-hc:latest -f Dockerfile .
docker build --build-arg TAG=2.0.18 -t mosquitto-hc:2.0.18 -f Dockerfile .
```

## Environment Variables

- **HEALTHCHECK_PORT**

  By default, a localhost listener on port `1880` is created to serve the healthcheck client. This can be overwritten by setting the `HEALTHCHECK_PORT` variable, for example:

  - cli

    ```bash
    docker run --rm -it --env=HEALTHCHECK_PORT=1881 -d mosquitto-hc:2.0.18
    ```

  - compose.yaml

    ```yaml
    version: '3.8'
    name: mosquitto
    services:
      mosquitto:
        container_name: mosquitto
        image: mosquitto-hc:latest
        restart: unless-stopped
        environment:
          HEALTHCHECK_PORT: 1881
        volumes:
          - config:/mosquitto/config
    ```
