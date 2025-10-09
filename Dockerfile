# syntax=docker/dockerfile:1

ARG TAG=latest

FROM eclipse-mosquitto:$TAG

# copy the new entrypoint and healthcheck scripts
COPY docker-entrypoint.sh check-health.sh /bin/

# rename the original entrypoint script, move and change permissions of the copied scripts
RUN mv /docker-entrypoint.sh /mosquitto-docker-entrypoint.sh \
    && mv /bin/docker-entrypoint.sh /docker-entrypoint.sh \
    && chmod 554 /mosquitto-docker-entrypoint.sh \
    && chmod 554 /docker-entrypoint.sh \
    && chmod 554 /bin/check-health.sh

# set the default healthcheck port, username, password and topic
ENV HEALTHCHECK_PORT="1880" \
    HEALTHCHECK_USERNAME="" \
    HEALTHCHECK_PASSWORD="" \
    HEALTHCHECK_TOPIC="\$SYS/broker/uptime"

# define the healthcheck tests parameters
HEALTHCHECK --start-period=20s --start-interval=2s --interval=10s --timeout=3s --retries=2 CMD /bin/check-health.sh

# run mosquitto with the modified configuration
CMD ["/usr/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto-with-healthcheck.conf"]

ARG TAG=latest
LABEL \
    org.opencontainers.image.authors="Guiorgy" \
    org.opencontainers.image.title="mosquitto-hc" \
    org.opencontainers.image.description="Eclipse Mosquitto MQTT Broker With Docker Healthchecks" \
    org.opencontainers.image.url="https://mosquitto.org/" \
    org.opencontainers.image.documentation="https://mosquitto.org/documentation/" \
    org.opencontainers.image.source="https://github.com/Guiorgy/MosquittoWithHealthCheck" \
    org.opencontainers.image.licenses="Apache-2.0" \
    org.opencontainers.image.version="$TAG"
