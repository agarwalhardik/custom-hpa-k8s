#!/usr/bin/env sh

# Replace proxy service variable
sed -e "s/%PROXY_SVC%/${PROXY_SVC}/g" /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

# Relaod the nginx configuration
nginx -s reload

# Run nginx & nginx prometheus exporter
nginx
/usr/bin/exporter -nginx.scrape-uri http://localhost/nginx_status