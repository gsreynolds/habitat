#!/bin/bash
# 5 env vars are required for this script
# HAB_ORIGIN_KEY
# BINTRAY_USER
# BINTRAY_PASSPHRASE
# BINTRAY_KEY
# BINTRAY_REPO
# TRAVIS_BUILD_NUMBER

set -euo pipefail

source .buildkite/scripts/shared.sh

# TODO (CM): We don't need this, since we can set environment
# variables in Buildkite automatically


# var_file="$HOME/tmp/our-awesome-vars"
# if [[ -f ${var_file} ]]; then
#   echo "--> Located the file with the magic environment variables."
#   source "${var_file}"
#   rm "${var_file}"
# else
#   echo "${var_file} does not appear to exist or at least not pass the -f test."
#   echo "This script will likely abort shortly."
# fi







# hab_src_dir="$HOME/code/$TRAVIS_BUILD_NUMBER/habitat"
# function cleanup {
#   echo "--> Removing origin secret keys from cache"
#   rm -f /hab/cache/keys/*-*.sig.key
#   echo "--> Purging directory '$hab_src_dir'"
#   rm -rf "$hab_src_dir"
# }
# trap cleanup EXIT

echo "--- Installing latest stable 'hab' binary from Homebrew"
brew tap habitat-sh/habitat
brew upgrade hab || brew install hab
hab --version

# Declaring this variable for the import_keys function only; see its
# documentation for further background.
#
# Alternatively, consider implementing set_hab_binary with platform-awareness

# declare -g isn't in the bash on our mac builders
bash --version

hab_binary="$(which hab)"
import_keys

# mac-build.sh is currently expecting things to be in /hab/cache/keys
sudo mkdir -p /hab/cache/keys
sudo cp ~/.hab/cache/keys/* /hab/cache/keys

echo "--- WHOAMI"
whoami

echo "--- Cleanup Homebrew after previous installs"
# TODO (CM): these are currently installed by mac-build.sh

deps=(coreutils
      gnu-tar
      wget
      bash
      rq
      zlib
      xz
      bzip2
      expat
      libsodium
      libiconv
      libarchive
      # openssl # installed by hab already
      hab-rq
      hab-libiconv
      hab-libarchive)
for dep in "${deps[@]}"; do
    brew uninstall "$dep" || true
done

echo "--- :rust: RUSTUP!"

# Ensure cache is clear of previous build artifacts for MAXIMUM PARANOIA
sudo rm -Rf /Users/build/.cargo

# Somehow the mac-build.sh rust installation isn't really working;
# might be sourcing
sudo /usr/local/lib/rustlib/uninstall.sh || true
curl https://sh.rustup.rs -sSf | sudo sh -s -- -y
#source $HOME/.cargo/env

rm -Rf /Users/build/.cargo

echo "--- :hammer_and_wrench: Building 'hab'"
cd ./components/hab/mac/

sudo DEBUG=1 ./mac-build.sh
# sudo ./components/hab/mac/mac-build.sh components/hab/mac
echo "Built new version of hab"







# bootstrap_dir="$HOME/mac_unstable/$TRAVIS_BUILD_NUMBER"
# mac_dir="${hab_src_dir}/components/hab/mac"
# mac_hab="${bootstrap_dir}/hab"
# gnu_tar=/usr/local/bin/tar
# hab_download_url="https://api.bintray.com/content/habitat/stable/darwin/x86_64/hab-%24latest-x86_64-darwin.zip?bt_package=hab-x86_64-darwin"
# our_path="${HOME}/.cargo/bin:/usr/local/bin:${PATH}"
# export HAB_ORIGIN=core
# export PATH="${our_path}"

# # start fresh
# rm -fr "${bootstrap_dir}"
# mkdir -p "${bootstrap_dir}"
# cd "${bootstrap_dir}"

# # this removes the link that was setup below, just in case it exists.
# # if we don't do this, then lots of tar related things fail
# if [[ -h $gnu_tar ]]; then
#   rm /usr/local/bin/tar
# fi

# # download a hab binary to get us started
# # wget -O hab.tar.gz "${hab_download_url}"

# # install it in a custom location
# # tar xvzf ./hab.tar.gz --strip 1 -C "${bootstrap_dir}"



# since this is running on a headless mac, we can't use docker/studio,
# so we need to resort to this hackery
# echo "--- Customizing bintray-publish"
# cp -v "$hab_src_dir"/components/bintray-publish/bin/publish-hab.sh "$bootstrap_dir"
# program=$bootstrap_dir/publish-hab.sh
# pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
# our_version=$(hab --version | cut -d ' ' -f 2)

# sed \
#   -e "s,#!/bin/bash$,#!$(brew --prefix bash)/bin/bash," \
#   -e "s,@author@,$pkg_maintainer,g" \
#   -e "s,@path@,$our_path,g" \
#   -e "s,@version@,$our_version,g" \
#   -e "s,tr --delete,tr -d,g" \
#   -e "s,sha256sum ,shasum -a 256 ,g" \
#   -i "" "$program"

# echo "Building hab"
# cd "$mac_dir"
# ./mac-build.sh
# echo "Built new version of hab"

# # link the brew installed gnu-tar to "tar" otherwise it won't get used
# # when publish-hab.sh runs and publish-hab.sh will abort
# ln -sf /usr/local/bin/gtar /usr/local/bin/tar
# hash -r

# cd "${bootstrap_dir}"

# echo "Publishing hab to $BINTRAY_REPO"
# # shellcheck disable=2061
# release=$(find "$mac_dir"/results -name "core-hab-0*.hart" | sort -n | tail -n 1)
# if [ "$BINTRAY_REPO" == "stable" ]; then
#   $program -s -r "$BINTRAY_REPO" "$release"
# else
#   $program -r "$BINTRAY_REPO" "$release"
# fi
# rm "$release"
# rm -rf "$bootstrap_dir"




# TODO (CM): Push to bintray LATER
