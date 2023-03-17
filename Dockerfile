FROM alpine:latest
LABEL maintainer="Kevin Ng <kng@mirantis.com> "

RUN apk add --no-cache bash curl jq

COPY swarm_core_info.sh /swarm_core_info.sh

RUN chmod 711 /swarm_core_info.sh

CMD ["/swarm_core_info.sh"]
