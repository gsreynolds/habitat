#!/bin/bash

# Download public and private keys for the "core" origin from Builder.
#
# Currently relies on a global variable `hab_binary` being set, since
# in the Linux build process, we need to switch binaries mid-way
# through the pipeline. As we bring more platforms into play, this may
# change. FYI.
import_keys() {
    echo "--- :key: Downloading 'core' public keys from Builder"
    ${hab_binary} origin key download core
    echo "--- :closed_lock_with_key: Downloading latest 'core' secret key from Builder"
    ${hab_binary} origin key download \
        --auth="${HAB_TEAM_AUTH_TOKEN}" \
        --secret \
        core
    # TODO (CM): delete the secret key later?
}
