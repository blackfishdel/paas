#!/bin/bash

#cd ~


#ls -an /usr/local/share


#app_path=/usr/local/share/
#ls ${app_path} | sed -i "s/^/"${app_path}"&/g"


#echo $(ls ${app_path})


#ls /usr/local/share | sed 's/^/aaa/'


#app_path="/usr/local/share/"
#ls ${app_path} | sed "s/^/"${app_path}"/"
#ls $app_path | awk '{print i$0}' i=`pwd`'/'


#touch test.txt
#echo '$'${app_path}'='${app_path} >> test.txt
#cat test.txt


#cat /etc/profile

实例4：改变指定目录以及其子目录下的所有文件的拥有者和群组 

命令：
chown -R -v root:mail test6


#curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
#sudo apt-get install -y nodejs


cd /home/delxie/Documents/repository-git/zkp-pbap-ui/pc
#通过在npm run build命令和参数之间添加两个破折号，可以将自定义参数传递给webpack ，例如npm run build -- --colors
#npm cache verify
#npm cache clean
#npm list

#npm init
#npm init -y
#npm install --save-dev webpack
#npm run build

#cat /home/delxie/.npm/_logs/2017-08-07T02_22_18_957Z-debug.log

#------------------------------------------------------------------------------
npm install
npm --buildVersion=v1.0.0 run build 

mv './dist' './pc_v1.0.0'
zip -r 'pc_v1.0.0.zip' './pc_v1.0.0'


iptables -A INPUT -p tcp --dport ssh -j ACCEPT
