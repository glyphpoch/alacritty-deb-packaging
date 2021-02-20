#!/bin/bash

set -xue

BASEDIR=${PWD}

# Install basic dependencies for downloading the source code and building a dev package
apt update && apt install -y \
    build-essential \
    debhelper \
    devscripts \
    equivs \
    wget \
    curl

# Install Rust & Cargo
export RUSTUP_HOME=${BASEDIR}/.rust
export CARGO_HOME=${BASEDIR}/.cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -qy --no-modify-path

# Get app version from the changelog
VERSION=$(dpkg-parsechangelog --show-field Version | sed -e "s/-[1-9][0-9]*$//g")

# Download source code
SOURCE_FILE_NAME="alacritty_${VERSION}.orig.tar.gz"
wget "https://github.com/alacritty/alacritty/archive/v${VERSION}.tar.gz" -O ${SOURCE_FILE_NAME}

# Extract source and set up the debian dir in it
SOURCE_DIR="alacritty-${VERSION}"
# The SOURCE_DIR directory will be implicitly created by tar when it extracts the source tarball
tar xf ${SOURCE_FILE_NAME}
mv ${BASEDIR}/debian/ ${BASEDIR}/${SOURCE_DIR}/

# Install the rest of the build dependencies
IGNORE_CARGO_DEPS_PROFILE_NAME=nocheck

# mk-build-deps will generate two files, so we want to run it outside
# the SOURCE_DIR to not pollute it. dpkg-buildpackage or dpkg-source
# will complain is the content of the SOURCE_DIR do not match the
# `orig` tarball although I'm not familiar with the details here so
# take this information with a grain of salt. This behaviour can also
# be work around by passing the `-nc`/`--no-pre-check` flag to debuild.
#
# nocheck build profile is set so that we skip the installation of cargo
# and rustc, name of the build profile can be anything - it just needs to
# match whatever profile `cargo` and `rustc` are to be ignored for in the
# `Build-Depends` in `debian/control`
mk-build-deps -i -r ${SOURCE_DIR}/debian/control --build-profiles=${IGNORE_CARGO_DEPS_PROFILE_NAME}

# Don't want to sign the package at the moment and also don't want to fail
# on the build-deps check because we're installing cargo manually.
debuild --prepend-path="${CARGO_HOME}/bin" \
    -eCARGO_HOME \
    -eRUSTUP_HOME \
    --unsigned-source \
    --unsigned-changes \
    --build-profiles=${IGNORE_CARG_DEPS_PROFILE_NAME}

