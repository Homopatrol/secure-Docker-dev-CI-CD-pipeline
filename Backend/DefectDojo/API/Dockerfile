FROM python:3.9.7-alpine3.13 

ARG UID=1001
ARG USER=ddcicd

USER root

RUN adduser -D -u ${UID} ${USER}
  
COPY --chown=${UID}:0 ./defectdojo_api/ /defectdojo_api/

USER ${UID}

RUN  pip install requests
