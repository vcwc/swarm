#!/usr/bin/env bash

envsubst < /vcw/pwd/urlrewrite.template > /vcw/pwd/urlrewrite.conf
envsubst < /vcw/pwd/urlrewrite.template > /etc/nginx/conf.d/urlrewrite.conf
nginx -g 'daemon off;'
