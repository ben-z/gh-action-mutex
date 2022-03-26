FROM alpine:3.10

COPY entrypoint.sh /entrypoint.sh
COPY entrypoint-post.sh /entrypoint-post.sh

ENTRYPOINT ["/entrypoint.sh"]
