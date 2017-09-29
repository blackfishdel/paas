#!/bin/bash -ex

git_base_url="ssh://jenkins@192.168.1.215:29418/joinwe"
project_path=$WORKSPACE'/'$project_name
web_point_list=("h5" "pc")

case $build_context in
"dev")
	project_postfix='SNAPSHOT'
	;;
"sit")
	project_postfix='ALPHA'
	;;
"uat")
	project_postfix='BETA'
	;;
"pro")
	project_postfix='RELEASE'
	;;
esac

#start
cd $WORKSPACE

#从git下载代码
git clone ${git_base_url}'/'${project_name}'.git'
cd $project_path

#切换分支或tag
if [ $now_branch ];then
	git checkout -b $now_branch 'origin/'$now_branch
	git pull
elif [ $now_tag ];then
	git checkout -b $now_tag $now_tag
	git pull
fi

#编译代码并压缩为zip
for ((i=0;i<${#web_point_list[@]};i++));do
	if [ ! -d $project_path'/'${web_point_list[$i]} ];then
		continue
	fi
	
	cd $project_path'/'${web_point_list[$i]}
	
	npm install
	npm --buildVersion=$project_version run build
	
	mv './dist' './'$project_name'_'${web_point_list[$i]}'_'$project_version
	zip -r $project_name'_'${web_point_list[$i]}'_'$project_version'_'$project_postfix'.zip' \
		'./'$project_name'_'${web_point_list[$i]}'_'$project_version
	
	rm -rf './node_modules'
done

