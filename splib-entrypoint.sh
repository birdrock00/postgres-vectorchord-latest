#!/bin/sh
# CMD wrapper: behaves like the official image's `CMD ["postgres", "-c",
# "shared_preload_libraries=..."]`, but the library list is read from the
# SHARED_PRELOAD_LIBRARIES env baked in at build time (vchord,vector for
# vchord-capable builds, vector for the vchord-less PG19 variant).
SPLO="${SHARED_PRELOAD_LIBRARIES:-vector}"
exec /docker-entrypoint.sh postgres -c "shared_preload_libraries=${SPLO}"
