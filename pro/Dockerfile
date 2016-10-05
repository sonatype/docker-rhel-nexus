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

FROM registry.access.redhat.com/rhel7/rhel
MAINTAINER Sonatype <cloud-ops@sonatype.com>
LABEL vendor=Sonatype \
  com.sonatype.license="Apache License, Version 2.0"

ENV NEXUS_VERSION 2.14.0-01
ENV NEXUS_HOME /opt/nexus/nexus
ENV NEXUS_WORK /sonatype-work
ENV NEXUS_REPOS /repositories
ENV APPLICATION_CONF /conf

ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 102
ENV JAVA_VERSION_BUILD 14

# Download Oracle JRE and localinstall with yum, yum install tar, yum clean
RUN curl --remote-name --fail --silent --location --retry 3 \
  --header "Cookie: oraclelicense=accept-securebackup-cookie; " \
  http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/jdk-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.rpm \
  && yum localinstall -y jdk-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.rpm \
  && rm jdk-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.rpm \
  && yum install -y tar  \
  && yum clean all

RUN mkdir -p ${NEXUS_HOME} \
  && curl --fail --silent --location --retry 3 \
    https://download.sonatype.com/nexus/professional-bundle/nexus-professional-${NEXUS_VERSION}-bundle.tar.gz \
  | gunzip \
  | tar x -C /tmp nexus-professional-${NEXUS_VERSION} \
  && mv /tmp/nexus-professional-${NEXUS_VERSION}/* ${NEXUS_HOME}/ \
  && rm -rf /tmp/nexus-professional-${NEXUS_VERSION} \
  && chmod 777 $NEXUS_HOME \
  && mkdir -p $NEXUS_WORK && chmod -R 777 $NEXUS_WORK \
  && mkdir -p $NEXUS_REPOS && chmod -R 777 $NEXUS_REPOS \
  && mkdir -p $APPLICATION_CONF && chmod -R 777 $APPLICATION_CONF

RUN useradd -r -u 200 -m -c "nexus role account" -d ${NEXUS_WORK} -s /bin/false nexus

COPY scripts/fix-permissions.sh /usr/local/bin/

RUN chmod 755 /usr/local/bin/fix-permissions.sh \
  && /usr/local/bin/fix-permissions.sh /opt/nexus \
  && /usr/local/bin/fix-permissions.sh $NEXUS_WORK \
  && /usr/local/bin/fix-permissions.sh $NEXUS_REPOS \
  && /usr/local/bin/fix-permissions.sh $NEXUS_HOME/conf \
  && /usr/local/bin/fix-permissions.sh $APPLICATION_CONF

VOLUME ["/sonatype-work"]
VOLUME ["/repositories"]

USER nexus

WORKDIR $NEXUS_HOME
ENV CONTEXT_PATH /
ENV MAX_HEAP 768m
ENV MIN_HEAP 256m
ENV JAVA_OPTS -server -XX:MaxPermSize=192m -Djava.net.preferIPv4Stack=true
ENV LAUNCHER_CONF ${NEXUS_HOME}/conf/jetty.xml ${NEXUS_HOME}/conf/jetty-requestlog.xml

EXPOSE 8081

CMD ${JAVA_HOME}/bin/java \
  -Dnexus-work=${NEXUS_WORK} -Dnexus-webapp-context-path=${CONTEXT_PATH} \
  -Dapplication-conf=${APPLICATION_CONF} \
  -Xms${MIN_HEAP} -Xmx${MAX_HEAP} \
  -cp 'conf/:lib/*' \
  ${JAVA_OPTS} \
  org.sonatype.nexus.bootstrap.Launcher ${LAUNCHER_CONF}
