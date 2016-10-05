#!/bin/bash

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

VERSION="$1"
VERSION="${VERSION,,}"
if [[ ${VERSION} != "pro" ]] && [[ ${VERSION} != "oss" ]]
then
  echo "Usage:"
  echo "  ./init.sh pro"
  echo "  ./init.sh oss"
  exit 1
fi

set -e

SCRIPT_BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Login Information
OPENSHIFT_CLI_USER="admin"
OPENSHIFT_CLI_PASSWORD="admin"
OPENSHIFT_NEXUS_PROJECT="nexus"

# Login to OpenShift
echo
echo "Logging into OpenShift..."
echo "=================================="
echo
oc login -u ${OPENSHIFT_CLI_USER} -p ${OPENSHIFT_CLI_PASSWORD}

# Create CI Project
echo
echo "Creating new Nexus Project (${OPENSHIFT_NEXUS_PROJECT})..."
echo "=================================="
echo
oc new-project ${OPENSHIFT_NEXUS_PROJECT}

echo
echo "Configuring project permissions..."
echo "=================================="
echo
# Grant Default CI Account Edit Access to All Projects and OpenShift Project
oc policy add-role-to-user edit system:serviceaccount:${OPENSHIFT_NEXUS_PROJECT}:default -n ${OPENSHIFT_NEXUS_PROJECT}

if [[ ${VERSION} == "oss" ]]
then

  # Process Nexus Template
  echo
  echo "Processing Nexus OSS Template..."
  echo "=================================="
  echo
  oc create -f "${SCRIPT_BASE_DIR}/nexus-oss.json" -n ${OPENSHIFT_NEXUS_PROJECT}

  sleep 10

  echo
  echo "Starting Nexus OSS binary build..."
  echo "=================================="
  echo
  oc start-build -n ${OPENSHIFT_NEXUS_PROJECT} nexus-oss --follow

else

  # Process Nexus Template
  echo
  echo "Processing Nexus Pro Template..."
  echo "=================================="
  echo
  oc create -f "${SCRIPT_BASE_DIR}/nexus-pro.json" -n ${OPENSHIFT_NEXUS_PROJECT}

  sleep 10

  echo
  echo "Starting Nexus Pro binary build..."
  echo "=================================="
  echo
  oc start-build -n ${OPENSHIFT_NEXUS_PROJECT} nexus-pro --follow

fi

sleep 10

# Go back to CI project
oc project ${OPENSHIFT_NEXUS_PROJECT}

echo
echo "=================================="
echo "Setup Complete!"
echo "=================================="
