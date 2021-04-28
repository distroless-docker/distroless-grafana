FROM debian:buster as builder

ARG ARCH=amd64
ARG GRAFANAARCH=amd64
ARG VERSION=7.5.4

RUN mkdir /work && mkdir /work/sources && mkdir /work/debs
WORKDIR /work

RUN echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list \
    && echo "deb-src http://deb.debian.org/debian-security/ buster/updates main" >> /etc/apt/sources.list \
    && echo "deb-src http://deb.debian.org/debian buster-updates main" >> /etc/apt/sources.list

RUN apt-get update && apt-get -y install \
    wget \
    && rm -rf /var/lib/apt/lists/*
    
ENV PKG=libc6
RUN dpkg --add-architecture ${ARCH} && \
    apt-get update && \
    for f in $(apt-cache depends $PKG:${ARCH} -qq --recurse --no-pre-depends --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances | sed 's/.*: //' | sort --unique); do wget $(apt-get install --reinstall --print-uris -qq $f | cut -d"'" -f2); done \
    && rm -rf /var/lib/apt/lists/* \
    && for f in ./*.deb; do dpkg -x $f out; done \
    && for f in ./*.deb; do cp $f debs/; done \
    && rm -rf *.deb
RUN dpkg --add-architecture ${ARCH} && \
    apt-get update && \
    apt-get source --print-uris -qq gcc-8-base | cut -d"'" -f2 && \
    for f in $(apt-cache depends $PKG:${ARCH} -qq --recurse --no-pre-depends --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances | sed 's/.*: //' | sort --unique); do echo $(apt-get source --print-uris -qq $f | cut -d"'" -f2) && wget $(apt-get source --print-uris -qq $f | cut -d"'" -f2) -P sources/ || true; done \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf *.tar.xz && rm -rf *.dsc
        
RUN mkdir licenses && for f in $(find /work/out/usr/share/doc/*/copyright -type f); do cp $f licenses/$(basename $(dirname $f))-$(find /work/debs | grep $(basename $(dirname $f)) | awk -F_ '{print $2}' | sed "s/-/_/"); done

WORKDIR /

RUN wget https://dl.grafana.com/oss/release/grafana-${VERSION}.linux-${GRAFANAARCH}.tar.gz
RUN tar -zxvf grafana-${VERSION}.linux-${GRAFANAARCH}.tar.gz
RUN cp /grafana-${VERSION}/LICENSE /work/licenses/grafana-${VERSION}

RUN mkdir -p /grafana-${VERSION}/data && chown -R 65534:65534 /grafana-${VERSION}

FROM scratch as image

ARG VERSION=7.5.4
USER 65534:65534
COPY --from=builder /grafana-${VERSION} /grafana
COPY --from=builder /work/out /
COPY --from=builder /work/licenses /licenses

EXPOSE 3000

WORKDIR /grafana

ENTRYPOINT ["/grafana/bin/grafana-server", "web"]
