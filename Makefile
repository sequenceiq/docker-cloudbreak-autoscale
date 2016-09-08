export MAVEN_METADATA_URL = maven.sequenceiq.com/releases/com/sequenceiq/periscope/maven-metadata.xml
export DOCKER_IMAGE = sequenceiq/periscope

dockerhub:
	./deploy.sh $(VERSION)
