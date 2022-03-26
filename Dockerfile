FROM alpine:3.10

RUN apk add github-cli

COPY entrypoint.sh /entrypoint.sh
COPY entrypoint-post.sh /entrypoint-post.sh

ENTRYPOINT ["/entrypoint.sh"]
