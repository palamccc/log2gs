FROM google/cloud-sdk:alpine
RUN apk add --no-cache curl ca-certificates \
  && cd /tmp \
  && curl -sO https://download.docker.com/linux/static/stable/x86_64/docker-18.06.1-ce.tgz \
  && tar -xvf docker*.tgz \
  && mv docker/docker /usr/local/bin \
  && rm -rf /tmp/*
COPY ./cronjob.sh /usr/local/bin/cronjob.sh
RUN chmod +x /usr/local/bin/cronjob.sh
RUN echo '*/5 * * * * /usr/local/bin/cronjob.sh' > /etc/crontabs/root
CMD [ "crond", "-f" ]