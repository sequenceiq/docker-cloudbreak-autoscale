FROM java:7
MAINTAINER SequenceIQ

ENV VERSION 0.5.2
# install the periscope app
ADD https://s3-eu-west-1.amazonaws.com/maven.sequenceiq.com/releases/com/sequenceiq/periscope/$VERSION/periscope-$VERSION.jar /periscope.jar

# Install zip
RUN apt-get update
RUN apt-get install zip

# extract schema files
RUN unzip periscope.jar schema/* -d /

ADD bootstrap /tmp

ENTRYPOINT ["/tmp/start_periscope.sh"]
