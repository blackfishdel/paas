#!/bin/bash -ex

cd ~/
curl -O 'https://nodejs.org/dist/v6.11.2/node-v6.11.2-linux-x64.tar.xz'
tar -xvJf 'node-v6.11.2-linux-x64.tar.xz'
mv './node-v6.11.2-linux-x64' '/usr/local/share/'
ln -s '/usr/local/share/node-v6.11.2-linux-x64/bin/node' '/usr/local/bin/'
ln -s '/usr/local/share/node-v6.11.2-linux-x64/bin/npm' '/usr/local/bin/'

rm -rf node-v6.11.2-linux-x64.tar.xz
