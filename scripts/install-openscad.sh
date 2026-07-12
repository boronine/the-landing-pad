#!/usr/bin/env bash
# Install the latest OpenSCAD development snapshot from the Debian/Ubuntu packages
# built on the OpenSUSE build service (https://build.opensuse.org/).
# See: https://openscad.org/downloads.html#snapshots
set -euo pipefail

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  SUDO="sudo"
fi

$SUDO apt-get update
$SUDO apt-get install -y ca-certificates curl

$SUDO curl -fsSL https://files.openscad.org/OBS-Repository-Key.pub \
  -o /etc/apt/trusted.gpg.d/obs-openscad-nightly.asc
echo 'deb https://download.opensuse.org/repositories/home:/t-paul/xUbuntu_24.04/ ./' \
  | $SUDO tee /etc/apt/sources.list.d/openscad.list > /dev/null

$SUDO apt-get update
$SUDO apt-get install -y openscad-nightly
$SUDO ln -sf /usr/bin/openscad-nightly /usr/local/bin/openscad
