#!/bin/sh
set -eu

DOMAIN="myfragrancesparfum.com"
WEBROOT="/var/www/html"
CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
KEY_PATH="/etc/letsencrypt/live/$DOMAIN/privkey.pem"

# Add all domains covered by the same certificate here.
DOMAINS="
myfragrancesparfum.com
www.myfragrancesparfum.com
n8n.myfragrancesparfum.com
adminer.myfragrancesparfum.com
"

HTTP_PID=""

cleanup() {
    if [ -n "$HTTP_PID" ]; then
        kill "$HTTP_PID" 2>/dev/null || true
        wait "$HTTP_PID" 2>/dev/null || true
        HTTP_PID=""
    fi
}

trap cleanup EXIT INT TERM

# Check whether a certificate exists and covers all configured domains.
NEEDS_CERT=0

if [ ! -f "$CERT_PATH" ] || [ ! -f "$KEY_PATH" ]; then
    NEEDS_CERT=1
else
    for domain in $DOMAINS; do
        if ! openssl x509 -in "$CERT_PATH" -noout -ext subjectAltName |
            grep -Fq "DNS:$domain"; then
            echo "Certificate does not cover $domain"
            NEEDS_CERT=1
        fi
    done
fi

if [ "$NEEDS_CERT" -eq 1 ]; then
    mkdir -p "$WEBROOT/.well-known/acme-challenge"

    echo "Starting temporary HTTP server on port 80..."
    python3 -m http.server 80 --directory "$WEBROOT" &
    HTTP_PID=$!

    sleep 2

    # Build the list of requested domains.
    set --
    for domain in $DOMAINS; do
        set -- "$@" -d "$domain"
    done

    echo "Requesting/updating Let's Encrypt certificate..."

    if [ -f "$CERT_PATH" ] && [ -f "$KEY_PATH" ]; then
        certbot certonly \
            --webroot \
            -w "$WEBROOT" \
            --cert-name "$DOMAIN" \
            --expand \
            "$@" \
            --non-interactive \
            --agree-tos \
            --register-unsafely-without-email
    else
        certbot certonly \
            --webroot \
            -w "$WEBROOT" \
            --cert-name "$DOMAIN" \
            "$@" \
            --non-interactive \
            --agree-tos \
            --register-unsafely-without-email
    fi

    echo "Stopping temporary HTTP server..."
    cleanup
    trap - EXIT INT TERM
else
    echo "Certificate already covers all configured domains."
fi

echo "Starting NGINX..."
exec nginx -g "daemon off;"