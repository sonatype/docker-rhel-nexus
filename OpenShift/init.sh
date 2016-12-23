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

# Create Nexus Project
echo
echo "Creating new Nexus Project (${OPENSHIFT_NEXUS_PROJECT})..."
echo "=================================="
echo
oc new-project ${OPENSHIFT_NEXUS_PROJECT}

echo
echo "Configuring project permissions..."
echo "=================================="
echo
# Grant Default Nexus Account Edit Access to All Projects and OpenShift Project
oc policy add-role-to-user edit system:serviceaccount:${OPENSHIFT_NEXUS_PROJECT}:default -n ${OPENSHIFT_NEXUS_PROJECT}
# Use anyuid SCC to allow Nexus to run as UID 200 
oc adm policy add-scc-to-group anyuid system:serviceaccounts:${OPENSHIFT_NEXUS_PROJECT}

echo
echo "Processing Nexus Template..."
echo "=================================="
echo
oc create -f "${SCRIPT_BASE_DIR}/nexus.json" -n ${OPENSHIFT_NEXUS_PROJECT}

echo
echo "Starting Nexus 2 binary build..."
echo "=================================="
echo
oc start-build -n ${OPENSHIFT_NEXUS_PROJECT} nexus --wait

echo
echo "Create Nexus Application..."
echo "=================================="
echo
oc new-app --template="nexus/nexus"

echo
echo "=================================="
echo "Setup Complete!"
echo "=================================="
