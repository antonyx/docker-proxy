#!/bin/sh

_trap() {
    local pid=1
    for p in /opt/*/; do
        service=`basename "$p"`
        eval "pid=\${pid${service}}"
        echo "Killing service: ${service} (${pid})..."
        kill ${pid} 2>/dev/null
    done
}
trap _trap SIGTERM SIGINT

start() {
    service=`basename "$1"`
    echo "Starting service: $service ..."
    cd /opt/$service
    /bin/sh ./run &
    lastPid=$!
    eval "pid${service}=${lastPid}"
}

if [ "${MODE}" = "tor" ]; then
    echo "forward-socks5t / localhost:9050 ." >> /opt/privoxy/config
    echo "include /opt/squid/privoxy.conf" >> /opt/squid/squid.conf
    if [ "${PRIVOXY_DEBUG}" ]; then
        echo "debug ${PRIVOXY_DEBUG:-}" >> /opt/privoxy/config
    fi
    start tor
    start privoxy
fi
start squid

# wait for services to exit
for p in /opt/*/; do
    service=`basename "$p"`
    pid=1
    eval "pid=\${pid${service}}"
    if [ $pid ]; then
        echo "Waiting for service to exit: ${service} (${pid})"
        wait ${pid}
    fi
done
