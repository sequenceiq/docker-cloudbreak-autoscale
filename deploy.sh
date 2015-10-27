install() {
  curl -L https://github.com/progrium/dockerhub-tag/releases/download/v0.2.0/dockerhub-tag_0.2.0_Darwin_x86_64.tgz | tar -xz -C /usr/local/bin/
}

new_version() {

  declare NEW_VERSION=${1:? version required}

  declare DOCKER_REPO:${2:? required cloudbreak/periscope/uluwatu-bin/sultans-bin}
  sed -i "/^ENV VERSION/ s/VERSION .*/VERSION ${NEW_VERSION}/" Dockerfile

  git commit -m "Release ${NEW_VERSION}" Dockerfile
  git tag ${NEW_VERSION}
  git push origin master --tags
  
  dockerhub-tag set sequenceiq/$DOCKER_REPO $NEW_VERSION $NEW_VERSION /
}

