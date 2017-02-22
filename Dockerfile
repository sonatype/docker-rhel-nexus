# Copyright (c) 2016-present Sonatype, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM       centos:centos7
MAINTAINER Sonatype <cloud-ops@sonatype.com>

# Atomic Labels
LABEL name="Nexus Repository Manager" \
      vendor="Sonatype" \
      version="3.2.1-01" \
      url="https://sonatype.com" \
      summary="The Nexus Repository Manager server \
          with universal support for popular component formats." \
      run="docker run -d --name NAME \
          -p 8081:8081 \
          IMAGE" \
      stop="docker stop NAME"

# OpenShift Labels
LABEL io.k8s.description="The Nexus Repository Manager server \
          with universal support for popular component formats." \
      io.k8s.display-name="Nexus Repository Manager" \
      io.openshift.expose-services="8081:8081" \
      io.openshift.tags="Sonatype,Nexus"

# Sonatype Labels
LABEL com.sonatype.license="Apache License, Version 2.0"

# Install Runtime Environment
ENV JAVA_VERSION_MAJOR=8 \
    JAVA_VERSION_MINOR=102 \
    JAVA_VERSION_BUILD=14

COPY help.1 /

RUN yum install -y --setopt=tsflags=nodocs curl tar && \
    yum clean all && \
    curl --remote-name --fail --silent --location --retry 3 \
        --header "Cookie: oraclelicense=accept-securebackup-cookie; " \
        http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/jdk-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.rpm && \
    yum localinstall -y jdk-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.rpm && \
    yum clean all && \
    rm jdk-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.rpm

# Install Nexus
ENV SONATYPE_DIR=/opt/sonatype
ENV NEXUS_DATA=/nexus-data \
    NEXUS_HOME=${SONATYPE_DIR}/nexus \
    NEXUS_VERSION=3.2.1-01 \
    SONATYPE_WORK=${SONATYPE_DIR}/sonatype-work \
    NEXUS_CONTEXT='' \
    USER_NAME=nexus \
    USER_UID=200

# Install Nexus and Configure Nexus Runtime Environment
RUN mkdir -p ${NEXUS_HOME} && \
    curl --fail --silent --location --retry 3 \
      https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz \
      | gunzip \
      | tar x -C ${NEXUS_HOME} --strip-components=1 nexus-${NEXUS_VERSION} && \
    chown -R root:root ${NEXUS_HOME} && \
    \
    sed \
      -e '/^nexus-context/ s:$:${NEXUS_CONTEXT}:' \
      -i ${NEXUS_HOME}/etc/nexus-default.properties && \
    \
    useradd -l -u ${USER_UID} -r -m -d ${NEXUS_DATA} -s /sbin/no-login \
            -c "${USER_NAME} application user" ${USER_NAME} && \
            mkdir -p ${NEXUS_DATA}/etc ${NEXUS_DATA}/log ${NEXUS_DATA}/tmp ${SONATYPE_WORK} && \
            ln -s ${NEXUS_DATA} ${SONATYPE_WORK}/nexus3 && \
            chown -R nexus:nexus ${NEXUS_DATA}

VOLUME ${NEXUS_DATA}

# Supply non variable to USER command ${USER_NAME}
USER nexus
# Supply non variable to WORKDIR command ${NEXUS_HOME}
WORKDIR /opt/sonatype/nexus

ENV JAVA_MAX_MEM=1200m \
    JAVA_MIN_MEM=1200m

EXPOSE 8081

CMD ["bin/nexus", "run"]
