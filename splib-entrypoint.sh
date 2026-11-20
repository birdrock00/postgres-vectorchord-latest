#!/bin/sh
# CMD wrapper: behaves like the official image's `CMD ["postgres", "-c",
# "shared_preload_libraries=..."]`, but the library list is read from the
# SHARED_PRELOAD_LIBRARIES env baked in at build time (vchord,vector for
# vchord-capable builds, vector for the vchord-less PG19 variant).
#
# The official entrypoint moved between majors: PG18 had it at
# /docker-entrypoint.sh (root), PG19 (trixie) ships it at
# /usr/local/bin/docker-entrypoint.sh and declares the ENTRYPOINT as the
# bare PATH-resolved name. Handle both layouts.
ENTRYPOINT_SCRIPT=/docker-entrypoint.sh
[ -x "$ENTRYPOINT_SCRIPT" ] || ENTRYPOINT_SCRIPT=/usr/local/bin/docker-entrypoint.sh

SPLO="${SHARED_PRELOAD_LIBRARIES:-vector}"
exec "$ENTRYPOINT_SCRIPT" postgres -c "shared_preload_libraries=${SPLO}"
