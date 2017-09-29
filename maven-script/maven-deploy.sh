#!/bin/bash -ex

maven_base_url="http://192.168.1.222:8081/nexus/content/repositories/"
snapshots_url="${maven_base_url}snapshots/"


cd /home/delxie/Documents/repository-git/commons/common-support

mvn install deploy -N -q -B -e -U -Dmaven.test.skip=true \
-DaltSnapshotDeploymentRepository="nexus-snapshots::default::${snapshots_url}"