FROM alpine:latest

RUN apk --no-cache add squid tor privoxy ca-certificates apache2-utils && \
    ln -sf /dev/stdout /var/log/privoxy/logfile && \
    chown -R squid:squid /var/cache/squid && \
    chown -R squid:squid /var/log/squid
COPY service /opt/

CMD ["/opt/entrypoint.sh"]

EXPOSE 8888
