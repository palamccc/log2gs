FROM google/cloud-sdk:alpine
RUN apk add --no-cache wget ca-certificates gzip \
  && cd /tmp \
  && wget https://download.docker.com/linux/static/stable/x86_64/docker-17.09.1-ce.tgz \
  && tar -xvf docker*.tgz \
  && mv docker/docker /usr/local/bin \
  && rm -rf /tmp/*