# Argument for the dynamic tag found via API
ARG VC_IMAGE_TAG

# Stage 1: Scratch layer from the dynamically tagged image
FROM tensorchord/vchord-postgres:${VC_IMAGE_TAG} AS vchord_scratch

# Stage 2: Final Image
FROM postgres:latest

# Argument for the specific .deb filename downloaded
ARG DEB_FILENAME

# Copy the downloaded .deb file from the build context
COPY ${DEB_FILENAME} /tmp/${DEB_FILENAME}

# Install dependencies and the VectorChord .deb
# We use 'apt-get install' on the local file to handle dependencies automatically
RUN apt-get update && \
    apt-get install -y /tmp/${DEB_FILENAME} && \
    rm -rf /tmp/${DEB_FILENAME} /var/lib/apt/lists/*

# Copy artifacts from the scratch stage (libraries, extensions, etc.)
COPY --from=vchord_scratch / /

# Set the startup command
CMD ["postgres", "-c" ,"shared_preload_libraries=vchord,vector"]
