FROM node:8 AS install

USER node

# Use non-root user for global dependencies.
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$PATH:/home/node/.npm-global/bin

# Install the latest version by default.
ARG VERSION=latest

# Install Composer.
RUN npm install --production -g composer-cli@${VERSION}

FROM node:8

USER node

# Reset npm logging to default level.
ENV NPM_CONFIG_LOGLEVEL warn

# Use non-root user for global dependencies.
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$PATH:/home/node/.npm-global/bin

COPY --chown=node:node --from=install /home/node/.npm-global /home/node/.npm-global

# Run in the node user home directory.
WORKDIR /home/node
