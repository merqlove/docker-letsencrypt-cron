FROM certbot/certbot:v1.32.2
MAINTAINER Alexander Merkulov <sasha@merqlove.ru>

VOLUME /certs
VOLUME /etc/letsencrypt
EXPOSE 80

RUN mkdir /scripts
RUN mkdir /secrets

ADD crontab /etc/crontabs
RUN crontab /etc/crontabs/crontab

RUN pip install --no-cache-dir certbot-dns-cloudflare awscli
RUN pip install --no-cache-dir "cloudflare>=2.3.1"

COPY ./scripts/ /scripts
RUN chmod +x /scripts/run_certbot.sh
RUN chmod +x /scripts/entrypoint.sh

ENTRYPOINT ["/scripts/entrypoint.sh"]
CMD ["crond", "-f"]
