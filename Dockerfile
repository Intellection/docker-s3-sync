FROM alpine:3.17

RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
      aws-cli \
      bash \
      dcron \
      libcap \
      inotify-tools \
      tini

ENV S3_SYNC_USER="s3sync"
ENV S3_SYNC_HOME="/home/${S3_SYNC_USER}"
RUN addgroup -g "9999" "${S3_SYNC_USER}" && \
    adduser -S -D -u "9999" -G "${S3_SYNC_USER}" "${S3_SYNC_USER}"

RUN touch /etc/crontabs/${S3_SYNC_USER} && \
    chown ${S3_SYNC_USER}:${S3_SYNC_USER} /etc/crontabs/${S3_SYNC_USER} && \
    chown ${S3_SYNC_USER}:${S3_SYNC_USER} /usr/sbin/crond && \
    setcap cap_setgid=ep /usr/sbin/crond

COPY entrypoint.sh /

USER ${S3_SYNC_USER}:${S3_SYNC_USER}

ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
