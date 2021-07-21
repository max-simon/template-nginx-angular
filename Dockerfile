FROM node:latest as build

ARG SKIP_TESTS=false
ARG NPM_TEST_SCRIPT="test:headless"
ARG NPM_BUILD_SCRIPT="build:prod"

# create directory
WORKDIR /opt/app-root/src/app

# install packages
COPY package.json package-lock.json ./ 
RUN npm ci 

# copy application data
COPY . . 
 
# run tests
RUN if [ "$SKIP_TESTS" = "false" ]; \
    then \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
    apt-get update && apt-get install -y google-chrome-stable; \
    export CHROME_BIN=/usr/bin/google-chrome; \
    npm run ${NPM_TEST_SCRIPT}; \
    else \
    echo "Skip tests"; \
    fi

# build application
RUN npm run ${NPM_BUILD_SCRIPT}

# Start from nginx
FROM registry.access.redhat.com/ubi8/nginx-118

# Specify which application (subfolder of dist) to use
ARG APPLICATION="main"

USER root
# Copying in source code
COPY --from=build /opt/app-root/src/app/dist/${APPLICATION} /tmp/src
COPY ./nginx/nginx.conf /tmp/src/nginx-default-cfg/default.conf
RUN ls /tmp/src
# Change file ownership to the assemble user. Builder image must support chown command.
RUN chown -R 1001:0 /tmp/src
USER 1001
# Assemble script sourced from builder image based on user input or image metadata.
# If this file does not exist in the image, the build will fail.
RUN /usr/libexec/s2i/assemble
# Run script sourced from builder image based on user input or image metadata.
# If this file does not exist in the image, the build will fail.
CMD /usr/libexec/s2i/run