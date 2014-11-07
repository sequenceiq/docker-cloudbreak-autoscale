FROM java:7
MAINTAINER SequenceIQ

ADD https://s3-eu-west-1.amazonaws.com/maven.sequenceiq.com/releases/com/sequenceiq/periscope/0.1.2/periscope-0.1.2.jar /periscope.jar

WORKDIR /

ENTRYPOINT ["java -jar /periscope.jar"]
