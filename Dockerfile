# Resilio Sync
#
# VERSION               0.1
#

FROM ubuntu:bionic AS unpacker

ARG VERSION=2.7.0
ARG ARCH=x64

ADD https://download-cdn.resilio.com/${VERSION}/linux-${ARCH}/resilio-sync_x64.tar.gz /tmp/sync.tgz
RUN tar -xf /tmp/sync.tgz -C /usr/bin rslsync && rm -f /tmp/sync.tgz

FROM ubuntu:bionic

ARG VERSION=2.7.0

LABEL MAINTAINER="Resilio Inc. <support@resilio.com>" \
      com.resilio.version="${VERSION}"

RUN apt-get update && \
    apt-get install -y gosu=1.10-1 --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/*/apt

COPY sync.conf.default /etc/
COPY run_sync /usr/bin/
COPY --from=unpacker /usr/bin/rslsync /usr/bin

# webui port
EXPOSE 8888/tcp

# listening port
EXPOSE 55555/tcp

# listening port
EXPOSE 55555/udp

# More info about ports used by Sync you can find here:
# https://help.resilio.com/hc/en-us/articles/204754759-What-ports-and-protocols-are-used-by-Sync-

VOLUME /mnt/sync

ENTRYPOINT ["run_sync"]
CMD ["--config", "/mnt/sync/sync.conf"]
