VERSION=7.5.4
DOCKERHUB=docker.io/distrolessdocker/distroless-grafana

docker build --build-arg VERSION=$VERSION --build-arg ARCH=amd64 --build-arg GRAFANAARCH=amd64 -t $DOCKERHUB:amd64-$VERSION .
docker build --build-arg VERSION=$VERSION --build-arg ARCH=armhf --build-arg GRAFANAARCH=armv7  -t $DOCKERHUB:armhf-$VERSION .
docker build --build-arg VERSION=$VERSION --build-arg ARCH=arm64 --build-arg GRAFANAARCH=arm64  -t $DOCKERHUB:arm64-$VERSION .
docker push $DOCKERHUB:amd64-$VERSION
docker push $DOCKERHUB:armhf-$VERSION
docker push $DOCKERHUB:arm64-$VERSION

docker build --build-arg VERSION=$VERSION --target image-sources --build-arg ARCH=amd64 --build-arg GRAFANAARCH=amd64 -t $DOCKERHUB:amd64-$VERSION-sources .
docker build --build-arg VERSION=$VERSION --target image-sources --build-arg ARCH=armhf --build-arg GRAFANAARCH=armv7  -t $DOCKERHUB:armhf-$VERSION-sources .
docker build --build-arg VERSION=$VERSION --target image-sources --build-arg ARCH=arm64 --build-arg GRAFANAARCH=arm64  -t $DOCKERHUB:arm64-$VERSION-sources .
docker push $DOCKERHUB:amd64-$VERSION-sources
docker push $DOCKERHUB:armhf-$VERSION-sources
docker push $DOCKERHUB:arm64-$VERSION-sources

DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend $DOCKERHUB:$VERSION $DOCKERHUB:amd64-$VERSION $DOCKERHUB:armhf-$VERSION $DOCKERHUB:arm64-$VERSION
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate $DOCKERHUB:$VERSION $DOCKERHUB:amd64-$VERSION --os linux --arch amd64
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate $DOCKERHUB:$VERSION $DOCKERHUB:armhf-$VERSION --os linux --arch arm --variant v7
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate $DOCKERHUB:$VERSION $DOCKERHUB:arm64-$VERSION --os linux --arch arm64 --variant v8
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push $DOCKERHUB:$VERSION

DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend $DOCKERHUB:$VERSION-sources $DOCKERHUB:amd64-$VERSION-sources $DOCKERHUB:armhf-$VERSION-sources $DOCKERHUB:arm64-$VERSION-sources
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate $DOCKERHUB:$VERSION-sources $DOCKERHUB:amd64-$VERSION-sources --os linux --arch amd64
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate $DOCKERHUB:$VERSION-sources $DOCKERHUB:armhf-$VERSION-sources --os linux --arch arm --variant v7
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate $DOCKERHUB:$VERSION-sources $DOCKERHUB:arm64-$VERSION-sources --os linux --arch arm64 --variant v8
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push $DOCKERHUB:$VERSION-sources

docker rmi $DOCKERHUB:amd64-$VERSION
docker rmi $DOCKERHUB:armhf-$VERSION
docker rmi $DOCKERHUB:arm64-$VERSION
docker rmi $DOCKERHUB:amd64-$VERSION-sources
docker rmi $DOCKERHUB:armhf-$VERSION-sources
docker rmi $DOCKERHUB:arm64-$VERSION-sources