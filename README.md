# Description

This Grafana container utilizes the officially binaries from Grafana.
The image is built upon docker scratch and builds libc6 from debian sources. 

# Usage

```sh
docker run -p 3000:3000 distroless/distroless-grafana:latest
```

# Licenses
This image itself is published under the `CC0 license`.

This image also contains:
- Grafana which is licensed under the `Apache 2.0`.

However, this image might also contain other software(parts) which may be under other licenses (such as OpenSSL or other dependencies). Some licenses are automatically collected and exported to the /licenses folder within the container. It is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

Source packages of the packages contained in this container are published in the container with the -sources tag.