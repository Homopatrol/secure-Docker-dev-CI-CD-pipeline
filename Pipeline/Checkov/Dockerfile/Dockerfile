# This is the Dockerfile for the image pandoraholladay/checkov:<tag>
# This Dockerfile adds the user checkov to the image bridgecrew/checkov and runs under the UID 1000 ensuring this container applies OpenShifts nonroot SCC
FROM bridgecrew/checkov:latest

ARG UID=1000
ARG GID=1000
ARG USERNAME=checkov

RUN addgroup -S -g ${GID} ${USERNAME} && \
    adduser -S -D -u ${UID} -G ${USERNAME} ${USERNAME} && \ 
    chown -R ${USERNAME}:0 /entrypoint.sh   && \
    chmod -R g=u /entrypoint.sh && \
    chown -R ${USERNAME}:0 /usr/local/lib/checkov-problem-matcher-softfail.json && \
    chown -R ${USERNAME}:0 /usr/local/lib/checkov-problem-matcher.json

USER ${UID}

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
