FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Extra tooling needed inside the dev container.
RUN apt-get update \
    && apt-get install -y make xvfb

# Install OpenSCAD using the same script the CI workflow uses.
COPY scripts/install-openscad.sh /tmp/install-openscad.sh
RUN /tmp/install-openscad.sh
