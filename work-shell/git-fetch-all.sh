#!/bin/bash -ex

GIT_ALL_PATH="/home/delxie/Documents/repository-git/"

#project array
project_array=("paas" "zkp-pbms" "zkp-pbap" "piculus" "zkp-pbap-ui" "bssp" "distribution")

for ((i=0;i<${#project_array[@]};i++));do
	cd ${GIT_ALL_PATH}
	cd ${project_array[${i}]}
	git fetch
done
