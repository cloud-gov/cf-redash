#!/bin/bash

# Note - full list of Redash environmental variables is here: 
#   https://redash.io/help/open-source/admin-guide/env-vars-settings

APP_NAME=$1

cf set-env $APP_NAME REDASH_DATABASE_URL ""     # Get by running cf enf APP_NAME
cf set-env $APP_NAME REDASH_LOG_LEVEL ""        # e.g., INFO
cf set-env $APP_NAME PYTHONUNBUFFERED ""        # e.g., 0
cf set-env $APP_NAME REDASH_REDIS_URL ""        # Get by running cf enf APP_NAME (Note, use rediss:// scheme)
cf set-env $APP_NAME REDASH_COOKIE_SECRET ""    # e.g., $(pwgen -1s 32)
cf set-env $APP_NAME REDASH_SECRET_KEY ""       # e.g., $(pwgen -1s 32)