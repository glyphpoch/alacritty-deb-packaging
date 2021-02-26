# Debian package builder for alacritty

This repository contains Debian packaging files, build scripts and a GitHub Actions workflow for building an alacritty Debian package.

# Usage
The `build.sh` script is meant to be called from within a docker/podman container, because we want a clean environment to build in. An alternative approach would be to use `pbuilder` or `sbuild` which build the package in a chroot environment.

Docker:
```sh
docker run \
    --rm \
    --privileged \
    --tmpfs /piutmp:exec,dev,rw \
    -v $PWD:/build \
    -w /build \
    ubuntu:20.10 \
    bash build.sh
```

Podman must be run with `sudo`, otherwise it's not possible for `piuparts` to create a chroot environment...:
```sh
sudo podman run \
    --rm \
    --privileged \
    --tmpfs /piutmp:exec,dev,rw \
    -v $PWD:/build \
    -w /build \
    ubuntu:20.10 \
    bash build.sh
```

It's possible to build the package without the `--privileged` and `--tmpfs` flags - these are only needed for `piuparts`. Just remove all the lines that call `pipuparts` from the `build.sh` script and then the package can be built with just:
```sh
podman run \
    --rm \
    -v $PWD:/build \
    -w /build \
    ubuntu:20.10 \
    bash build.sh
```

# Creating a new release

Creating new releases via GitHub Actions is as simple as updating the changelog with:
```sh
dch --controlmaint --newversion 0.7.2-1 --distribution $(lsb_release -c -s) --urgency low
```
or with the shorter version:
```sh
dch -M -v 0.7.2-1 -D $(lsb_release -c -s) -u low
```

And then pushing the changes to GitHub.

The `--controlmain`/`-M` option will populate the new changelog entry with maintainer information from the `debian/control` file. Omit the flag if that is not desired.

**IMPORTANT**: Version numbers should always be in the following format: `${ALACRITTY_VERSION}-([1-9][0-9]*)`. This format is expected by the build script so that it can fetch the correct alacritty source tarball.

# TODOs
* Sign the packages produced by GitHub Actions
* Push the packages directly into a PPA instead of creating releases.
* Find a sensible workaround for running piuparts without putting containers into privileged mode.

# Helpful links
* <https://wiki.debian.org/Packaging/Intro?action=show&redirect=IntroDebianPackaging>
* <https://vincent.bernat.ch/en/blog/2019-pragmatic-debian-packaging>
* <https://github.com/barnumbirr/alacritty-debian>
