FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install the latest OpenSCAD snapshot AppImage as `openscad`.
# The releases PPA does not publish noble/24.04 packages, so we use the
# upstream nightly AppImage instead.
ARG OPENSCAD_APPIMAGE_URL=https://files.openscad.org/snapshots/OpenSCAD-2026.07.11-x86_64.AppImage
ARG OPENSCAD_APPIMAGE_SHA256=7bb85a974a5a4b063f6a094513ed408347221e3de4c04919c4012c81f9a80d76

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        libegl1 \
        libfontconfig1 \
        libfreetype6 \
        libgl1 \
        libglx-mesa0 \
        libharfbuzz0b \
        libopengl0 \
        libwayland-client0 \
        make \
        xvfb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/openscad.appimage "${OPENSCAD_APPIMAGE_URL}" \
    && echo "${OPENSCAD_APPIMAGE_SHA256}  /tmp/openscad.appimage" | sha256sum -c - \
    && chmod +x /tmp/openscad.appimage \
    && cd /tmp \
    && /tmp/openscad.appimage --appimage-extract >/dev/null \
    && mv /tmp/squashfs-root /openscad \
    && rm -f /tmp/openscad.appimage \
    && ln -s /openscad/AppRun /usr/local/bin/openscad
