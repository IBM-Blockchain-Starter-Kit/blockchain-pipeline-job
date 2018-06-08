FROM node:8 AS build

USER node

RUN mkdir -p /home/node/bin

# Use non-root user for global dependencies.
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

# Install Composer, using latest version by default.
ARG COMPOSER_VERSION=latest
RUN npm install --production -g composer-cli@${COMPOSER_VERSION}

# Install jq.
ENV JQ_VERSION='1.5'
RUN wget --no-check-certificate https://raw.githubusercontent.com/stedolan/jq/master/sig/jq-release.key -O /tmp/jq-release.key
RUN wget --no-check-certificate https://raw.githubusercontent.com/stedolan/jq/master/sig/v${JQ_VERSION}/jq-linux64.asc -O /tmp/jq-linux64.asc
RUN wget --no-check-certificate https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 -O /tmp/jq-linux64
RUN gpg --import /tmp/jq-release.key
RUN gpg --verify /tmp/jq-linux64.asc /tmp/jq-linux64
RUN cp /tmp/jq-linux64 /home/node/bin/jq
RUN chmod +x /home/node/bin/jq

# Prepare to copy build results into final image.
RUN mkdir -p /home/node/build
RUN mv /home/node/.npm-global /home/node/build/.npm-global
RUN mv /home/node/bin /home/node/build/bin

FROM node:8

USER node

ENV PATH=$PATH:/home/node/bin:/home/node/.npm-global/bin

# Reset npm logging to default level.
ENV NPM_CONFIG_LOGLEVEL warn

# Use non-root user for global dependencies.
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

# Copy results of build stage.
COPY --chown=node:node --from=build /home/node/build /home/node

# Run in the node user home directory.
WORKDIR /home/node
