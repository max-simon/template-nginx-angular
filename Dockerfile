FROM node:latest as build

# install chromium
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
    apt-get update && apt-get install -y google-chrome-stable
ENV CHROME_BIN=/usr/bin/google-chrome

# create directory
WORKDIR /opt/app-root/src/app

# install packages
COPY package.json package-lock.json ./ 
RUN npm ci 

# copy application data
COPY . . 
 
# run tests
RUN npm run test:headless

# build application
RUN npm run build --output-path=dist --configuration=production

# Start from nginx
FROM registry.access.redhat.com/ubi8/nginx-118

# Set a build argument for the application name
ARG APPLICATION="main"

# Copy the nginx configuration
COPY ./nginx/nginx.conf /opt/app-root/etc/nginx.default.d/default.conf

# Copy build from the 'build environment'
COPY --from=build /opt/app-root/src/app/dist/${APPLICATION} /opt/app-root/src/

CMD nginx -g "daemon off;"