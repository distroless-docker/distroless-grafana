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
    for f in $(apt-cache depends $PKG:${ARCH} -qq --recurse --no-pre-depends --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances | sed 's/.*: .*//' | sed 's/<.*>//' | sed -e 's/^[ \t]*//' | sort --unique); do echo $(apt-get -y install --print-uris --reinstall --no-install-recommends $f |  grep -E 'https://|http://' | tr -d "'" | awk '{print$1}'); done > packages && \
    cat packages | sed 's/ /\n/g' | sort --unique | wget -i - \
    && rm -rf /var/lib/apt/lists/* \
    && for f in ./*.deb; do dpkg -x $f out; done \
    && for f in ./*.deb; do cp $f debs/; done \
    && rm -rf *.deb
RUN dpkg --add-architecture ${ARCH} && \
    apt-get update && \
    for f in $(apt-cache depends $PKG:${ARCH} -qq --recurse --no-pre-depends --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances | sed 's/.*: .*//' | sed 's/<.*>//' | sed -e 's/^[ \t]*//' | sort --unique); do echo $f && echo $(apt-get source --print-uris $f |  grep -E 'https://|http://' | tr -d "'" | awk '{print$1}'); done > packages && cat packages && \
    cat packages | sed 's/ /\n/g' | sort --unique | wget -P sources/ -i - || true \
    && rm -rf /var/lib/apt/lists/*
        
RUN mkdir licenses && for f in $(find /work/out/usr/share/doc/*/copyright -type f); do cp $f licenses/$(basename $(dirname $f))-$(find /work/debs | grep $(basename $(dirname $f)) | awk -F_ '{print $2}' | sed "s/-/_/"); done

WORKDIR /

RUN wget https://dl.grafana.com/oss/release/grafana-${VERSION}.linux-${GRAFANAARCH}.tar.gz
RUN tar -zxvf grafana-${VERSION}.linux-${GRAFANAARCH}.tar.gz
RUN cp /grafana-${VERSION}/LICENSE /work/licenses/grafana-${VERSION}

RUN mkdir -p /grafana-${VERSION}/data && chown -R 65534:65534 /grafana-${VERSION}

FROM scratch as image-sources
COPY --from=builder /work/sources /

FROM scratch as image

ARG VERSION=7.5.4
USER 65534:65534
COPY --from=builder /grafana-${VERSION} /grafana
COPY --from=builder /work/out /
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /work/licenses /licenses

EXPOSE 3000

WORKDIR /grafana

ENTRYPOINT ["/grafana/bin/grafana-server", "web"]
