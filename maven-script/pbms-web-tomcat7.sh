#!/bin/bash -ex

maven_base_url="http://192.168.1.222:8081/nexus/content/repositories/"
snapshots_url="${maven_base_url}snapshots/"


cd /home/delxie/Documents/repository-git/zkp-pbap
mvn -N -q -B -e -U -Dmaven.test.skip=true package deploy \
-Dmaven.repo.local="${maven_repository}" \
-DaltSnapshotDeploymentRepository="nexus-snapshots::default::${snapshots_url}"

cd /home/delxie/Documents/repository-git/zkp-pbms/pbms-web

mvn -Dmaven.test.skip=true package tomcat7:redeploy



