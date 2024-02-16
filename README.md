# Mosquitto Docker Image With Health Checks

Containers built with this Dockerfile pull the [Eclipse Mosquitto](https://github.com/eclipse/mosquitto/tree/master/docker) image and extend it by adding a heanthcheck test.

## Environment Variables

- **HEALTHCHECK_PORT**

  By default, a localhost listener on port `1880` is created to serve the healthcheck client. This can be overwritten by setting the `HEALTHCHECK_PORT` variable, for example:

  - shell

    ```bash
    docker run --rm -it --env=HEALTHCHECK_PORT=1881 -d mosquitto-hc:latest
    ```

  - compose.yaml

    ```yaml
    ...
    services:
      mosquitto:
        image: mosquitto-hc:latest
        environment:
          HEALTHCHECK_PORT: 1881
        ...
    ```

- **HEALTHCHECK_USERNAME** and **HEALTHCHECK_PASSWORD**

  By default, a new listener with anonumous login is created to serve the healthcheck client. This can be overwritten by setting the `HEALTHCHECK_USERNAME` and `HEALTHCHECK_PASSWORD` variables, in which case, an existing listener will be used instead of creating a new one. For example:

  - shell

    ```bash
    docker run --rm -it --env=HEALTHCHECK_USERNAME=testUser --env=HEALTHCHECK_PASSWORD=testPaswd -d mosquitto-hc:latest
    ```

  - compose.yaml

    ```yaml
    ...
    services:
      mosquitto:
        image: mosquitto-hc:latest
        environment:
          HEALTHCHECK_USERNAME: testUser
          HEALTHCHECK_PASSWORD: testPaswd
        ...
    ```

- **HEALTHCHECK_TOPIC**

  By default, the healthcheck client subscribes to the `$SYS/broker/uptime` topic. This can be overwritten by setting the `HEALTHCHECK_TOPIC` variable. This is useful if an existing listener is used that disables the `$SYS` hierarchy completely. **Note**, that subscribing to the selected topic should imidiately return a value, otherwise the healthcheck will time out. For example:

  - shell

    ```bash
    docker run --rm -it --env=HEALTHCHECK_TOPIC=test/topic -d mosquitto-hc:latest
    ```

  - compose.yaml

    ```yaml
    ...
    services:
      mosquitto:
        image: mosquitto-hc:latest
        environment:
          HEALTHCHECK_TOPIC: test/topic
        ...
    ```

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
docker compose build
```
