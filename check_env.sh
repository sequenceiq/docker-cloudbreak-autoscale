#!/bin/bash

: ${PERISCOPE_SMTP_USERNAME:?"SMTP username is missing from env_props.sh"}
: ${PERISCOPE_SMTP_PASSWORD:?"SMTP password is missing from env_props.sh"}
: ${PERISCOPE_SMTP_HOST:?"SMTP host is missing from env_props.sh"}
: ${PERISCOPE_STMP_PORT:?"SMTP port is missing from env_props.sh"}
: ${PERISCOPE_SMTP_FROM:?"SMTP from is missing from env_props.sh"}

: ${PERISCOPE_CLOUDBREAK_URL:?"Cloudbreak's address is missing from env_props.sh"}
: ${PERISCOPE_IDENTITY_SERVER_URL:?"The identity server's URL is missing from env_props.sh"}
: ${PERISCOPE_CLIENT_SECRET:?"Periscope's UAA client secret is missing from env_props.sh"}

echo Starting Periscope with the following settings:

for p in "${!PERISCOPE_@}"; do
  echo $p=${!p}
done
