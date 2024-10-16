ARG BASE_IMAGE=debian:12-slim

FROM ${BASE_IMAGE} AS BASE
ARG WAHOOMC_VERSION=4.3.0

# Install System Dependencies
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
  DEBIAN_FRONTEND=noninteractive apt-get -qq -y update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends \
    curl \
    default-jre \
    osmium-tool \
    osmosis \
    python3 \
    python3-geojson \
    python3-pip \
    python3-requests \
    python3-shapely \
    python3-tk \
    gdal-bin \
    python3-gdal \
    zip \
    lzma
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# Install wahoomc
RUN --mount=type=cache,target=/root/.cache/pip \
  pip install --break-system-packages \
    wahoomc==$WAHOOMC_VERSION

# For contours
RUN --mount=type=cache,target=/tmp \
    curl -L http://katze.tfiu.de/projects/phyghtmap/phyghtmap_2.23.orig.tar.gz -o /tmp/phyghtmap_2.tar.gz && \
    echo "8c0eae73f1d576b0d0177357d026eee30325e1249dedc03f54ebed451cc3b013 /tmp/phyghtmap_2.tar.gz" | sha256sum --check --status && \
    tar -xzf /tmp/phyghtmap_2.tar.gz -C /tmp && \
    cd /tmp/phyghtmap-2.23 && python3 setup.py install

# Set up runtime environment
RUN mkdir -p /app
WORKDIR "/app"
RUN python3 -c "from wahoomc import main; main.run('init')"

ENTRYPOINT ["python3", "-m", "wahoomc"]
