# This is the Dockerfile for the image pandoraholladay/kics:<tag>
# This Dockerfile adds the user kics to the image checkmarx/kics and runs under the UID 1000 ensuring this container applies OpenShifts nonroot SCC
FROM checkmarx/kics:latest

ARG UID=1000
ARG GID=1000
ARG USERNAME=kics

RUN addgroup -S -g ${GID} ${USERNAME} && \
    adduser -S -D -u ${UID} -G ${USERNAME} ${USERNAME} && \ 
    chown -R ${USERNAME}:0 /app/bin/kics && \
    chmod -R g=u /app/bin/kics
    
USER ${UID}

ENTRYPOINT ["/app/bin/kics"]
