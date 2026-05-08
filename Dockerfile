# Stage 1: Final Image
FROM postgres:latest

# Argument for the specific .deb filename downloaded
ARG DEB_FILENAME

# Copy the downloaded .deb file from the build context
COPY ${DEB_FILENAME} /tmp/${DEB_FILENAME}

# Install pgvector, PostGIS, and the VectorChord .deb
# PG_MAJOR is an environment variable set in the official postgres image (e.g., "17")
# This ensures we install extension packages matching the postgres version.
RUN apt-get update && \
    apt-get install -y postgresql-${PG_MAJOR}-pgvector postgresql-${PG_MAJOR}-postgis-3 /tmp/${DEB_FILENAME} && \
    rm -rf /tmp/${DEB_FILENAME} /var/lib/apt/lists/*

# Set the startup command
CMD ["postgres", "-c" ,"shared_preload_libraries=vchord,vector"]
