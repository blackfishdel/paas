#!/bin/bash -ex

cd /home/delxie/Documents/repository-git/scripts

touch README.md
git init
git add README.md
git commit -m "init commit"
git push -u origin master