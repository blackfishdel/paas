#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"

while [ -h ${SOURCE} ];do
	DIR=$( cd -P $( dirname ${SOURCE} ) && pwd )
	SOURCE="$(readlink ${SOURCE})"
	[[ ${SOURCE} != /* ]] && SOURCE=${DIR}/${SOURCE}
done

BASEDIR="$( cd -P $( dirname ${SOURCE} ) && pwd )"
cd ${BASEDIR}

docker build -t zkpregistry.com:5043/tomcat-test:0.0.2 -f ${BASEDIR}/Dockerfile ${BASEDIR}/
