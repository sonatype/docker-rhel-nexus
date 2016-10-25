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

FROM       registry.access.redhat.com/rhel7/rhel
MAINTAINER Sonatype <cloud-ops@sonatype.com>

# Atomic Labels
LABEL name="Nexus Repository Manager" \
      vendor="Sonatype" \
      version="3.0.2-02" \
      url="https://sonatype.com" \
      summary="The Nexus Repository Manager server \
          with universal support for popular component formats." \
      run="docker run -d --name ${NAME} \
          -p 8081:8081 \
          ${IMAGE}" \
      stop="docker stop ${NAME}"

# OpenShift Labels
LABEL io.k8s.description="The Nexus Repository Manager server \
          with universal support for popular component formats." \
      io.k8s.display-name="Nexus Repository Manager" \
      io.openshift.expose-services="8081:8081" \
      io.openshift.tags="Sonatype,Nexus"

# Sonatype Labels
LABEL com.sonatype.license="Apache License, Version 2.0"

# Install Runtime Environment
RUN set -x && \
    yum clean all && \
    yum-config-manager --disable \* && \
    yum-config-manager --enable rhel-7-server-rpms && \
    yum-config-manager --enable rhel-7-server-thirdparty-oracle-java-rpms && \
    yum -y update-minimal --security --sec-severity=Important --sec-severity=Critical --setopt=tsflags=nodocs && \
    yum -y install --setopt=tsflags=nodocs tar java-1.8.0-oracle-devel && \
    yum clean all

# Install Nexus
ENV NEXUS_DATA=/nexus-data \
    NEXUS_HOME=/opt/sonatype/nexus \
    NEXUS_VERSION=3.0.2-02 \
    USER_NAME=nexus \
    USER_UID=200

RUN mkdir -p ${NEXUS_HOME} && \
    curl --fail --silent --location --retry 3 \
      https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz \
      | gunzip \
      | tar x -C ${NEXUS_HOME} --strip-components=1 nexus-${NEXUS_VERSION}

# Configure Nexus Runtime Environment
RUN sed \
    -e "s|karaf.home=.|karaf.home=${NEXUS_HOME}|g" \
    -e "s|karaf.base=.|karaf.base=${NEXUS_HOME}|g" \
    -e "s|karaf.etc=etc|karaf.etc=${NEXUS_HOME}/etc|g" \
    -e "s|java.util.logging.config.file=etc|java.util.logging.config.file=${NEXUS_HOME}/etc|g" \
    -e "s|karaf.data=data|karaf.data=${NEXUS_DATA}|g" \
    -e "s|java.io.tmpdir=data/tmp|java.io.tmpdir=${NEXUS_DATA}/tmp|g" \
    -i ${NEXUS_HOME}/bin/nexus.vmoptions

RUN useradd -l -u ${USER_UID} -r -g 0 -m -d ${NEXUS_DATA} -s /sbin/no-login \
            -c "${USER_NAME} application user" ${USER_NAME}

VOLUME ${NEXUS_DATA}

# Supply non variable to USER command ${USER_NAME}
USER nexus
# Supply non variable to WORKDIR command ${NEXUS_HOME}
WORKDIR /opt/sonatype/nexus

ENV JAVA_MAX_MEM=1200m \
    JAVA_MIN_MEM=1200m

EXPOSE 8081

CMD ["bin/nexus", "run"]
