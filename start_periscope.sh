#!/bin/bash

check-docker-version() {
  DOCKER_VER=$(docker version|sed -n "/Server version/ {s/.*:.//; s/\.//gp}")
  if [ $DOCKER_VER -lt 111 ]; then
    cat <<EOF

=============================================
= ERROR                                     =
= You are using an old version of Docker =
= Please upgrade it to at least 1.1.1       =
=============================================
EOF
    exit -1
  fi
}

check-docker-version

: ${PERISCOPE_HBM2DDL_STRATEGY:=create}
: ${PERISCOPE_DB_PORT_5432_TCP_PORT:=5432}
: ${PERISCOPE_SMTP_FROM:=no-reply@sequenceiq.com}
: ${PERISCOPE_SMTP_PORT:=587}
: ${PERISCOPE_CLIENT_ID:=periscope}
: ${PERISCOPE_CLIENT_SECRET:=periscopesecret}
: ${PERISCOPE_SERVER_PORT:=8081}

: ${PERISCOPE_DOCKER_IMAGE_TAG:=latest}

#docker pull sequenceiq/periscope:$PERISCOPE_DOCKER_IMAGE_TAG

# Removes previous containers
docker inspect peripostgresql &>/dev/null && docker rm -f peripostgresql

# Start a postgres database docker container
docker run -d --name="peripostgresql" -p 5432:5432 postgres

timeout=10
echo "Wait $timeout seconds for the POSTGRES DB to start up"
sleep $timeout

# Start the Periscope application
docker run -d --name="periscope" \
-e "PERISCOPE_HBM2DDL_STRATEGY=$PERISCOPE_HBM2DDL_STRATEGY" \
-e "PERISCOPE_DB_PORT_5432_TCP_PORT=$PERISCOPE_DB_PORT_5432_TCP_PORT" \
-e "PERISCOPE_SMTP_HOST=$PERISCOPE_SMTP_HOST" \
-e "PERISCOPE_SMTP_USERNAME=$PERISCOPE_SMTP_USERNAME" \
-e "PERISCOPE_SMTP_PASSWORD=$PERISCOPE_SMTP_PASSWORD" \
-e "PERISCOPE_SMTP_FROM=$PERISCOPE_SMTP_FROM" \
-e "PERISCOPE_SMTP_PORT=$PERISCOPE_SMTP_PORT" \
-e "PERISCOPE_DB_PORT_5432_TCP_ADDR=$PERISCOPE_DB_PORT_5432_TCP_ADDR" \
-e "PERISCOPE_CLOUDBREAK_URL=$PERISCOPE_CLOUDBREAK_URL" \
-e "PERISCOPE_IDENTITY_SERVER_URL=$PERISCOPE_IDENTITY_SERVER_URL" \
-e "PERISCOPE_CLIENT_ID=$PERISCOPE_CLIENT_ID" \
-e "PERISCOPE_CLIENT_SECRET=$PERISCOPE_CLIENT_SECRET" \
-p $PERISCOPE_SERVER_PORT:8080 \
sequenceiq/periscope:$PERISCOPE_DOCKER_IMAGE_TAG

PERISCOPE_ADDR=$(docker inspect -f "{{.NetworkSettings.IPAddress}}" periscope)

cat <<EOF
================================================================
Periscope is running on: $PERISCOPE_ADDR:$PERISCOPE_SERVER_PORT
================================================================
EOF
