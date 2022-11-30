FROM alpine:latest
MAINTAINER Greg Huebner <ghuebner@mirantis.com>

RUN apk add --no-cache bash curl jq

COPY swarm_core_info.sh /swarm_core_info.sh

CMD ["/swarm_core_info.sh"]
