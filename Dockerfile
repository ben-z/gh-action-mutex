FROM ${ARG_BASE_IMAGE}

RUN  apk update \
  && apk add --no-cache bash curl git

COPY rootfs/ /
