# Stage 1: Final Image
#
# PostgreSQL 19 (floating `postgres:19` = latest 19.x) with pgvector,
# PostGIS, and VectorChord when a VectorChord .deb exists for this PG major.
#
# VectorChord gap: as of PG19's release tensorchord only ships prebuilt
# .debs/images for PG14-PG18 (pgrx 0.17, feature flags pg14..pg18; no pg19
# deb, image or source support). The build workflow therefore passes
# VCHORD_DEB_URL="" until a VectorChord release with a pg19 .deb lands, and
# this image then builds WITHOUT vchord and preloads only `vector` — it can
# host every database that does not use vchord indexes. When a pg19 vchord
# .deb exists, simply re-run the workflow (no code change) and the same
# Dockerfile produces the full vchord+vector image.
FROM postgres:19

# Prebuilt VectorChord .deb download URL + filename for PG19
# (empty string = build the vchord-less variant).
ARG VCHORD_DEB_URL=""
ARG VCHORD_DEB_NAME=""
# Baked into the SHARED_PRELOAD_LIBRARIES env: "vchord,vector" when a vchord
# .deb was installed, "vector" in the vchord-less variant.
ARG VCHORD_PRELOAD=vector
ENV SHARED_PRELOAD_LIBRARIES=$VCHORD_PRELOAD

# Install pgvector, PostGIS, and (optionally) the VectorChord .deb.
# PG_MAJOR is an environment variable set in the official postgres image (e.g., "19");
# this ensures we install extension packages matching the postgres version.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        postgresql-${PG_MAJOR}-pgvector postgresql-${PG_MAJOR}-postgis-3 wget && \
    if [ -n "$VCHORD_DEB_URL" ]; then \
        wget -q -O "/tmp/${VCHORD_DEB_NAME}" "$VCHORD_DEB_URL" && \
        apt-get install -y "/tmp/${VCHORD_DEB_NAME}" && \
        rm -f "/tmp/${VCHORD_DEB_NAME}"; \
    fi && \
    apt-get purge -y --auto-remove wget && \
    rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint-initdb.d/10-enable-postgis.sh /docker-entrypoint-initdb.d/10-enable-postgis.sh
COPY splib-entrypoint.sh /usr/local/bin/splib-entrypoint
RUN chmod +x /usr/local/bin/splib-entrypoint

# Same behaviour as the official `postgres` entrypoint, but
# shared_preload_libraries comes from the build-time env so the vchord-less
# variant never preloads a library that is not installed.
CMD ["sh", "/usr/local/bin/splib-entrypoint"]
