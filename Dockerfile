FROM certbot/certbot:v1.32.2
MAINTAINER Alexander Merkulov <sasha@merqlove.ru>

VOLUME /certs
VOLUME /etc/letsencrypt
EXPOSE 80

RUN mkdir /scripts

ADD crontab /etc/crontabs
RUN crontab /etc/crontabs/crontab

COPY ./scripts/ /scripts
RUN chmod +x /scripts/run_certbot.sh

ENTRYPOINT []
CMD ["crond", "-f"]
