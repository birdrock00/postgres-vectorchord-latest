# Stage 1: Final Image
FROM postgres:latest

# Argument for the specific .deb filename downloaded
ARG DEB_FILENAME

# Copy the downloaded .deb file from the build context
COPY ${DEB_FILENAME} /tmp/${DEB_FILENAME}

# Install the VectorChord .deb
# The deb package handles placing files in the correct Postgres extension directory
RUN apt-get update && \
    apt-get install -y /tmp/${DEB_FILENAME} && \
    rm -rf /tmp/${DEB_FILENAME} /var/lib/apt/lists/*

# Set the startup command
CMD ["postgres", "-c" ,"shared_preload_libraries=vchord,vector"]
