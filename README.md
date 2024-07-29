# docker-proxy

A docker image with Squid, Privoxy and Tor based on Alpine Linux.

By default, this image operates as a Squid-based proxy server. It can also be configured to run in Tor mode, where traffic is routed through the Tor network for enhanced privacy.

In normal mode, the image functions as a standard Squid proxy server, providing caching and request modification.

In Tor mode:
- It changes IP address in every 2 minutes by default. You can specify the IP_CHANGE_INTERVAL environment variable to change the behaviour.
- Privoxy is used for midifying requests between Squid and Tor.
- Squid as used well for caching and midifying requests.

## normal mode
```
docker run -d -e PROXY_AUTH=0 -p 8888:8888 -p testapp/proxy
```

## tor mode
```
docker run -d -e PROXY_AUTH=0 -e MODE=tor -e IP_CHANGE_INTERVAL=120 -p 8888:8888 -p testapp/proxy
curl --proxy localhost:8888 http://ipecho.net/
```

## Squid settings

You can change squid settings by mount a custom.conf into /opt/squid/custom.conf:

```
docker run -d -e IP_CHANGE_INTERVAL=120 -v $PWD/custom.conf:/opt/squid/custom.conf -p 8888:8888 -p testapp/proxy
```

The image has an URL rewrite script to be able to modify request URLs. You can configure it by mounting a file into /opt/squid/rewriter.conf like this:
```
# URL rewriter: change in the server, not in the browser
SED="$SED;s|^http://\(.*google\)\.hu|\1.com|g"

# URL redirect in the browser with HTTP status code 302
SED="$SED;s|^http://\(.*google\)\.com|302:\1.hu|g"
```

## Authentication

To enable authentication, set the PROXY_AUTH environment variable to 1. You can specify the username and password with the PROXY_USER and PROXY_PASS environment variables.

```
docker run -d -e PROXY_AUTH=1 -e PROXY_USER="user" -e PROXY_PASS="password123" -p 8888:8888 testapp/proxy
curl --proxy-user user:password123 --proxy localhost:8888 http://ipecho.net/
```

### Create or set a password for a user

To create a user and set a password:

```
htpasswd -b -c service/squid/passwd john insecure-password
```

### Change password inside a running container

To change a password for a user inside a running container:

```
docker exec -it http-proxy htpasswd -b -c /opt/squid/passwd john new-password
```
