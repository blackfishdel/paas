#!/bin/bash -ex

git_branch=4.2.0-dev
merge_branch=3.9.0-dev

GIT_ALL_PATH="/home/delxie/Documents/repository-git/"

cd $GIT_ALL_PATH'/zkp-pbap'

git fetch --all

git stash save -a

git checkout $git_branch
git merge 'origin/'$git_branch

git merge --no-ff 'origin/'$merge_branch

git stash pop