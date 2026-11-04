#!/usr/bin/env bash

# Usage: bash maven.env.sh <maven-version>
#    <maven-version> example:
#      - 3.9.12
#
# https://dlcdn.apache.org/maven/maven-3/3.9.12/binaries/apache-maven-3.9.12-bin.tar.gz

if [ ! -f "${HOME:?}/Applications/apache-maven-${1:?}/bin/mvn" ]; then
  maven_version="${1:?}" && \
  echo "$(date -R) [ INFO ] apache-maven-${maven_version:?} is installing ..." && \
  rm    -r -f "${HOME:?}/Applications/apache-maven-${maven_version:?}/" && \
  mkdir -p    "${HOME:?}/Applications/" && \
  file_name="apache-maven-${maven_version}-bin.tar.gz" && \
  # download and extract
  (
    cd "${HOME}/Applications/" && \
    curl \
      --fail \
      --location \
      --output "${file_name}" \
      "https://dlcdn.apache.org/maven/maven-3/${maven_version}/binaries/${file_name}" && \
    echo "$(date -R) [ INFO ] apache-maven-${maven_version} downloaded at ${HOME}/Applications/${file_name}" && \
    tar -zxf "${file_name}" && \
    rm "${file_name}"
  ) && \
  echo "$(date -R) [ INFO ] apache-maven-${maven_version} installed."
fi && \
export M2_HOME="${HOME}/Applications/apache-maven-${1:?}" && \
export PATH="${M2_HOME}/bin:${PATH}"
