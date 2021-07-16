FROM registry.access.redhat.com/ubi8/nodejs-14 as build

WORKDIR /opt/app-root/src/app

# Install npm production packages
COPY package.json .
RUN npm install && \
    npm install -g @angular/cli

# Copy source code
COPY . .

# Build application
RUN npm run build --output-path=dist --configuration=production

# Start from nginx
FROM registry.access.redhat.com/ubi8/nginx-118

# Set a build argument for the application name
ARG APPLICATION="main"

# Copy the nginx configuration
COPY ./ops/nginx.conf /opt/app-root/etc/nginx.default.d/default.conf

# Copy build from the 'build environment'
COPY --from=build /opt/app-root/src/app/dist/${APPLICATION} /opt/app-root/src/

CMD nginx -g "daemon off;"