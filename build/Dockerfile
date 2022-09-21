FROM node:13.6.0-alpine

ARG IMAGE_CREATE_DATE
ARG IMAGE_VERSION

# Metadata as defined in OCI image spec annotations - https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.title="Hello World!" \
      org.opencontainers.image.description="Provides a demo image to deploy to a cluster" \
      org.opencontainers.image.created=$IMAGE_CREATE_DATE \
      org.opencontainers.image.version=$IMAGE_VERSION

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json /usr/src/app/
RUN npm install

# Bundle app source
COPY . /usr/src/app

USER node
CMD [ "npm", "start" ]