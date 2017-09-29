#!/bin/bash -ex

#------------------------------------------------------------------------------
#variable
#------------------------------------------------------------------------------
#工作空间目录
WORKSPACE=${WORKSPACE}
#构建环境
build_context=${build_context}
#------------------------------------------------------------------------------
#constant
#------------------------------------------------------------------------------
git_base_url="ssh://jenkins@192.168.1.215:29418/joinwe/"
maven_base_url="http://192.168.1.222:8081/nexus/content/repositories/"
snapshots_url="${maven_base_url}snapshots/"
alpha_url="${maven_base_url}alpha/"
beta_url="${maven_base_url}beta/"
releases_url="${maven_base_url}releases/"

#------------------------------------------------------------------------------
#名字:fun_version_change
#描述:修改构建项目后缀
#范例:fun_version_change "sit" "/project_file_path"
#$1:构建环境
#$2:项目路径
#------------------------------------------------------------------------------
fun_version_change(){
cd ${2}
pompath=$(find ${2} -maxdepth 1 -name 'pom.xml')
if [ ! ${pompath} ];then
	echo "[warn] ${2} pom.xml is did not find!"
	return 0;
fi
case ${1} in
"dev")
;;
"sit")
mvn versions:set -N -q -B -e -U -Dmaven.test.skip=true \
-DremoveSnapshot=true -DnewVersion='${project.version}' \
-DupdateMatchingVersions=false
mvn versions:set -N -q -B -e -U -Dmaven.test.skip=true \
-DremoveSnapshot=true -DnewVersion='${project.version}-ALPHA' \
-DupdateMatchingVersions=false
;;
"uat")
mvn versions:set -N -q -B -e -U -Dmaven.test.skip=true \
-DremoveSnapshot=true -DnewVersion='${project.version}' \
-DupdateMatchingVersions=false
mvn versions:set -N -q -B -e -U -Dmaven.test.skip=true \
-DremoveSnapshot=true -DnewVersion='${project.version}-BETA' \
-DupdateMatchingVersions=false
;;
"pro")
mvn versions:set -N -q -B -e -U -Dmaven.test.skip=true \
-DremoveSnapshot=true -DnewVersion='${project.version}' \
-DupdateMatchingVersions=false
mvn versions:set -N -q -B -e -U -Dmaven.test.skip=true \
-DremoveSnapshot=true -DnewVersion='${project.version}-RELEASE' \
-DupdateMatchingVersions=false
;;
esac
}
#------------------------------------------------------------------------------
#名字:fun_dependency_change
#描述:修改构建项目依赖版本号，注意：如果nexus没有该版本，则修改失败
#注意:pom中properties中名字要与artifactId一样
#范例:fun_dependency_change "sit" "/project_file_path"
#$1:构建环境
#$2:项目路径
#$3:属性名称
#$4:版本号
#------------------------------------------------------------------------------
fun_dependency_change(){
cd ${2}
pompath=$(find ${2} -maxdepth 1 -name 'pom.xml')
if [ ! ${pompath} ];then
	echo "[warn] ${2} pom.xml is did not find!"
else
	case ${1} in
"dev")
	echo "[info] context:dev is not change!"
	;;
"sit")
	mvn versions:update-property -q -B -e -U -Dmaven.test.skip=true \
	-DallowSnapshots=true -Dproperty="${3}.version" -DnewVersion="[${4}-ALPHA]"
	;;
"uat")
	mvn versions:update-property -q -B -e -U -Dmaven.test.skip=true \
	-DallowSnapshots=true -Dproperty="${3}.version" -DnewVersion="[${4}-BETA]"
	;;
"pro")
	mvn versions:update-property -q -B -e -U -Dmaven.test.skip=true \
	-DallowSnapshots=true -Dproperty="${3}.version" -DnewVersion="[${4}-RELEASE]"
	;;
	esac
fi
}
#------------------------------------------------------------------------------
#名字:fun_deploy_nexus
#描述:发布项目到nexus仓库
#范例:fun_deploy_nexus "sit" "/project_file_path"
#$1:构建环境
#$2:项目路径
#------------------------------------------------------------------------------
fun_deploy_nexus(){
cd ${2}
pompath=$(find ${2} -maxdepth 1 -name 'pom.xml')
if [ ! ${pompath} ];then
	echo "[warn] ${2} pom.xml is did not find!"
else
	case ${1} in
"dev")
	mvn install deploy -N -q -B -e -U -Dmaven.test.skip=true \
	-Dmaven.repo.local="${maven_repository}" \
	-DaltSnapshotDeploymentRepository="nexus-snapshots::default::${snapshots_url}"
	;;
"sit")
	mvn install deploy -N -q -B -e -U -Dmaven.test.skip=true \
	-Dmaven.repo.local="${maven_repository}" \
	-DaltReleaseDeploymentRepository="nexus-snapshots::default::${alpha_url}"
	;;
"uat")
	mvn install deploy -N -q -B -e -U -Dmaven.test.skip=true \
	-Dmaven.repo.local="${maven_repository}" \
	-DaltReleaseDeploymentRepository="nexus-snapshots::default::${beta_url}"
	;;
"pro")
	mvn install deploy -N -q -B -e -U -Dmaven.test.skip=true \
	-Dmaven.repo.local="${maven_repository}" \
	-DaltReleaseDeploymentRepository="nexus-snapshots::default::${releases_url}"
	;;
	esac
	if [ $? != 0 ];then
		echo "[warn] ${2} this project deploy failed!"
	fi
fi
}
#------------------------------------------------------------------------------
#名字:fun_package_pro
#描述:编译项目
#范例:fun_package_pro "/project_file_path"
#$1:项目路径
#------------------------------------------------------------------------------
fun_package_pro(){
cd ${1}
mvn clean package -q -B -e -U -Dmaven.test.skip=true \
-Dmaven.repo.local="${maven_repository}"
}
#------------------------------------------------------------------------------
#名字:fun_push_image
#描述:构建image发布到registry
#范例:fun_push_image "/project_file_path"
#$1:项目路径
#------------------------------------------------------------------------------
fun_push_image(){
cd ${1}
mvn docker:build -q -B -e -U -Dmaven.test.skip=true -DpushImage
}
#------------------------------------------------------------------------------
#名字:fun_zip_url
#描述:组合git下载url
#范例:fun_zip_url "project_name"
#$1:项目名称
#$2:分支名称或tag名称
#------------------------------------------------------------------------------
fun_zip_url(){
zip_url="http://192.168.1.215:9090/zip/?r=joinwe/${1}.git&h=${2}&format=zip"
echo ${zip_url}
}
#------------------------------------------------------------------------------
#名字:fun_unzip_file
#描述:解压文件到指定目录，并删除原文件
#范例:fun_unzip_file "/zip_file_path" "/dir_path"
#$1:文件路径
#$1:目录路径
#------------------------------------------------------------------------------
fun_unzip_file(){
unzip -q -d "${1}" "${2}"
rm -rf "${1}"
}
#------------------------------------------------------------------------------
#名字:fun_backup_file
#描述:备份文件到指定地址
#范例:fun_backup_file "/project_file_path"
#$1:文件路径
#------------------------------------------------------------------------------
fun_backup_file(){
scp "${1}" "root@192.168.1.215:/home/test-version/joinwe/"
}
#------------------------------------------------------------------------------
#名字:fun_create_script
#描述:创建增量包“删除文件脚本”
#范例:fun_backup_file "/dir_path"
#------------------------------------------------------------------------------
fun_create_script(){
cat << "EOF" >> "${WORKSPACE}/remove_file.sh"
#!/bin/bash
#BASEDIR解决获得脚本存储位置绝对路径
#这个方法可以完美解决别名、链接、source、bash -c 等导致的问题
SOURCE="${BASH_SOURCE[0]}"
while [ -h ${SOURCE} ];do
	DIR=$( cd -P $( dirname ${SOURCE} ) && pwd )
	SOURCE="$(readlink ${SOURCE})"
	[[ ${SOURCE} != /* ]] && SOURCE=${DIR}/${SOURCE}
done
BASE_DIR="$( cd -P $( dirname ${SOURCE} ) && pwd )"
cd ${BASE_DIR}
EOF
}
#------------------------------------------------------------------------------
#名字:fun_superadd_script
#描述:在“删除文件脚本”文件末尾添加内容
#范例:fun_backup_file "/dir_path"
#$1:内容
#------------------------------------------------------------------------------
fun_superadd_script(){
echo "${1}" >> "${WORKSPACE}/remove_file.sh"
}
#------------------------------------------------------------------------------
#init
#------------------------------------------------------------------------------
cd ${WORKSPACE}
base_dir="${WORKSPACE}/base_dir"
mkdir -p "${WORKSPACE}/base_dir"
mv $(ls -a | grep -v "^base_dir$" | grep -v "\.$" | grep -v "\.\.$") \
	"${base_dir}"
#修改分支或标签
if [ ${now_branch} ];then
	cd ${base_dir}
	git checkout -b "${now_branch}" "origin/${now_branch}"
	git pull
elif [ ${now_tag} ];then
	cd ${base_dir}
	git checkout -b "${now_tag}" "${now_tag}"
fi
#------------------------------------------------------------------------------
#create maven_repository
#------------------------------------------------------------------------------
maven_repository="${WORKSPACE}/maven_repository"
rm -rf ${maven_repository}
mkdir -p ${maven_repository}

#------------------------------------------------------------------------------
#read build.json
#------------------------------------------------------------------------------
description_path="$(find ${base_dir} -name build.json | head -n 1)"
if [ ${description_path} ];then
	description_find='find'
else
	description_find='not find'
fi

case ${description_find} in
'not find')
echo "[warn] ${base_dir} build.json is did not find!"
;;
'find')
json_description=$(cat ${description_path})
json_dependencies=$(echo ${json_description} | jq ".dependencies")
json_dependencies_length=$(echo ${json_dependencies} | jq length)

if [ json_dependencies_length == 0 ];then
	dependencies_build="false"
else
	dependencies_build="true"
fi
;;
esac

#------------------------------------------------------------------------------
#build dependencies
#------------------------------------------------------------------------------
case ${dependencies_build} in
"false")
echo "[warn] This project does not need to dependencies!"
;;
"true")
cd ${WORKSPACE}
dependency_dir="${WORKSPACE}/dependency_dir"
mkdir -p ${dependency_dir}
#递归遍历dependencies
jq_dependencies=($(echo ${json_description} | jq "recurse(.dependencies[]) | .dependencies | tostring"))
for ((i=${#jq_dependencies[@]};i>0;i--));do
	jq_i=`expr i-1`
	jq_dependency=$(echo ${jq_dependencies[${jq_i}]} | jq "fromjson")
	jq_dependency_length=$(echo ${jq_dependency} | jq length)
	if [ ${jq_dependency_length} > 0 ];then
		for ((j=0;j<${jq_dependency_length};j++));do
			#获取参数
			jq_project=$(echo ${jq_dependency} \
				| jq ".[${j}] | .project" | sed {s/\"//g})
			jq_version=$(echo ${jq_dependency} \
				| jq ".[${j}] | .version" | sed {s/\"//g})
			jq_branch=$(echo ${jq_dependency} \
				| jq ".[${j}] | .branch"  | sed {s/\"//g})
			jq_tag=$(echo ${jq_dependency} \
				| jq ".[${j}] | .tag" | sed {s/\"//g})
			
			#从git下载代码
			cd ${dependency_dir}
			git clone "${git_base_url}${jq_project}.git"
			cd "${dependency_dir}/${jq_project}"
			
			#切换分支或tag
			if [ ${jq_branch} ];then
				git checkout -b ${jq_branch} "origin/${jq_branch}"
				git pull
			elif [ ${jq_tag} ];then
				git checkout -b "${jq_tag}" "${jq_tag}"
				git pull
			fi
			
			#判断父pom是否有外部依赖
			if [[ $(echo ${jq_dependency} | jq ".[${j}] | .dependencies | .[] | .modules") && \
				$(echo ${jq_dependency} | jq ".[${j}] | .dependencies | .[] | .modules") != "null" ]];then
				#获取参数
				jq_names=$(echo ${jq_dependency} \
					| jq ".[${j}] | .dependencies | .[] | .modules | .[] | .name" | sed {s/\"//g})
				jq_values=$(echo ${jq_dependency} \
					| jq ".[${j}] | .dependencies | .[] | .modules | .[] | .version" | sed {s/\"//g})
				
				#修改父pom外部依赖版本号
				if [ ${#jq_names[@]} != 0 ];then
					for ((k=0;k<${#jq_names[@]};k++));do
						fun_dependency_change "${build_context}" "${dependency_dir}/${jq_project}" \
						"${jq_names[${k}]}" "${jq_values[${k}]}"
					done
				fi
			fi
			
			#修改父pom版本号
			fun_version_change "${build_context}" "${dependency_dir}/${jq_project}"
			
			#判断父pom是否有子项目
			if [[ $(echo ${jq_dependency} | jq ".[${j}] | .modules") && \
				$(echo ${jq_dependency} | jq ".[${j}] | .modules") != "null" ]];then
				#获取参数
				jq_sub_names=($(echo ${jq_dependency} \
					| jq ".[${j}] | .modules | .[] | .name" | sed {s/\"//g}))
				jq_sub_values=($(echo ${jq_dependency} \
					| jq ".[${j}] | .modules | .[] | .version" | sed {s/\"//g}))
				
				#修改子项目pom版本号
				if [ ${#jq_sub_names[@]} != 0 ];then
					for ((k=0;k<${#jq_sub_names[@]};k++));do
						fun_version_change "${build_context}" \
						"${dependency_dir}/${jq_project}/${jq_sub_names[${k}]}"
					done
				fi
			fi
			
			#父项目打包上传到nexus
			set +e
			fun_deploy_nexus "${build_context}" "${dependency_dir}/${jq_project}"
			set -e
			#判断父pom是否有子项目
			if [[ $(echo ${jq_dependency} | jq ".[${j}] | .modules") && \
				$(echo ${jq_dependency} | jq ".[${j}] | .modules") != "null" ]];then
				#获取参数
				jq_sub_names=($(echo ${jq_dependency} \
					| jq ".[${j}] | .modules | .[] | .name" | sed {s/\"//g}))
				jq_sub_values=($(echo ${jq_dependency} \
					| jq ".[${j}] | .modules | .[] | .version" | sed {s/\"//g}))
				#子项目打包上传到nexus
				if [ ${#jq_sub_names[@]} != 0 ];then
					for ((k=0;k<${#jq_sub_names[@]};k++));do
						set +e
						fun_deploy_nexus "${build_context}" \
						"${dependency_dir}/${jq_project}/${jq_sub_names[${k}]}"
						set -e
					done
				fi
			fi
			
			#删除该项目文件夹
			cd ${dependency_dir}
			rm -rf ${jq_project}
		done
	fi
done
;;
esac

# 删除dependency_dir
rm -rf ${dependency_dir}

#------------------------------------------------------------------------------
#create remove script
#------------------------------------------------------------------------------
fun_create_script

#------------------------------------------------------------------------------
#build target project
#------------------------------------------------------------------------------
cd ${WORKSPACE}
project_name=$(echo ${json_description} | \
	jq '.project_name' | sed {s/\"//g})
web_module=$(echo ${json_description} | \
	jq '.web_module' | sed {s/\"//g})
last_tag=$(echo ${json_description} | \
	jq '.last_tag' | sed {s/\"//g})

master_dir="${WORKSPACE}/master_dir"
mkdir -p ${master_dir}
#判断该项目是否第一次发布
if [ ${now_branch} ];then
	if [ ${now_branch} != ${last_tag} ];then
		#以发布过，有master分支，有tag分支，有patch包
		project_tag="patch"
	elif [ ${now_branch} = ${last_tag} ];then
		#未发布过，没有master分支，没有tag分支,没有patch包
		project_tag="full"
	fi
elif [ ${now_tag} ];then
	if [ ${now_tag} != ${last_tag} ];then
		#以发布过，有master分支，有tag分支，有patch包
		project_tag="patch"
	elif [ ${now_tag} = ${last_tag} ];then
		#未发布过，没有master分支，没有tag分支,没有patch包
		project_tag="full"
	fi
fi
#------------------------------------------------------------------------------
case ${project_tag} in
'patch')
master_zip_url=$(fun_zip_url ${project_name} "master")
master_zip_path="${WORKSPACE}/master.zip"

#下载master分支
curl -o "${master_zip_path}" "${master_zip_url}"
unzip -q -d "${master_dir}" "${master_zip_path}"
rm -rf ${master_zip_path}

#对比branch与master修改文件
diff_file_list=($(diff -ruaq "${base_dir}" "${master_dir}" \
		| grep '^Files' | grep -v '\.git' | awk '{print $2}' ))
#对比branch有，master没有的文件
#屏蔽没有后缀的列，认为没有“.”的列为文件夹
#屏蔽master的文件列，默认为master需要文件
add_file_list=($(diff -ruaq "${base_dir}" "${master_dir}" \
		| grep '^Only' | grep "${base_dir}" | grep -v '\.git' \
		| awk '{print $3,$4;}' | sed 's/: /\//' ))
	
#屏蔽master的文件列，默认为master需要文件
remove_file_list=($(diff -ruaq "${base_dir}" "${master_dir}" \
		| grep '^Only' | grep "${master_dir}" | grep -v '\.git' \
		| awk '{print $3,$4;}' | sed 's/: /\//' ))

#把branch的add\diff文件复制到master
if [[ ${#diff_file_list[@]} != 0 ]];then
	for i in ${!diff_file_list[@]};do
		dir_path="${diff_file_list[$i]/${base_dir}/${master_dir}}"
		mkdir -p $(dirname "${dir_path}")
		if [ -d ${diff_file_list[$i]} ];then
			continue
		fi
		cp "${diff_file_list[$i]}" "${dir_path}"
	done
fi

if [[ ${#add_file_list[@]} != 0 ]];then
	for i in ${!add_file_list[@]};do
		if [ -d ${add_file_list[$i]} ];then
			dir_path="${add_file_list[$i]/${base_dir}/${master_dir}}"
			mkdir -p "${dir_path}"
			cp -r "${add_file_list[$i]}" $(dirname "${dir_path}")
		else
			dir_path="${add_file_list[$i]/${base_dir}/${master_dir}}"
			mkdir -p $(dirname "${dir_path}")
			cp "${add_file_list[$i]}" "${dir_path}"
		fi
	done
fi

if [[ ${#remove_file_list[@]} != 0 ]];then
	for i in ${!remove_file_list[@]};do
		rm -f "${remove_file_list[$i]}"
	done
fi
#------------------------------------------------------------------------------
#对master_dir修改版本号
cd ${master_dir}

#循环遍历最外层dependencies数组，修改父pom外部依赖
for ((i=0;i<${#jq_dependencies[@]};i++));do
	jq_dependency=$(echo ${jq_dependencies[${i}]} | jq "fromjson")
	jq_dependency_length=$(echo ${jq_dependency} | jq length)
	#判断dependency数组是否为空
	if [ ${jq_dependency_length} > 0 ];then
		#循环遍历dependency数组
		for ((j=0;j<${jq_dependency_length};j++));do
			#判断dependency数组是否有子项目
			if [[ $(echo ${jq_dependency} | jq ".[${j}] | .modules") && \
				$(echo ${jq_dependency} | jq ".[${j}] | .modules") != "null" ]];then
				#获取参数
				jq_sub_names=($(echo ${jq_dependency} \
					| jq ".[${j}] | .modules | .[] | .name" | sed {s/\"//g}))
				jq_sub_values=($(echo ${jq_dependency} \
					| jq ".[${j}] | .modules | .[] | .version" | sed {s/\"//g}))
				#获取依赖并修改pom版本号
				if [ ${#jq_sub_names[@]} != 0 ];then
					for ((k=0;k<${#jq_sub_names[@]};k++));do
						fun_dependency_change "${build_context}" "${master_dir}" \
							"${jq_sub_names[$k]}" "${jq_sub_values[$k]}"
					done
				fi
			fi
		done
	fi
done

#修改父pom版本号
fun_version_change "${build_context}" "${master_dir}"

#获取参数
jq_sub_names=($(echo ${json_description} | jq '.modules | .[] | .name' | sed {s/\"//g}))

#修改子项目pom版本号
if [ ${#jq_sub_names[@]} != 0 ];then
	for ((i=0;i<${#jq_sub_names[@]};i++));do
		if [[ ${jq_sub_names[$i]} != ${project_name} || ${jq_sub_names[$i]} != ${web_module} ]];then
			fun_version_change "${build_context}" "${master_dir}/${jq_sub_names[$i]}"
		fi
	done
fi

#父项目整体编译打包并上传到nexus
fun_deploy_nexus "${build_context}" "${master_dir}"

#修改子项目pom版本号
if [ ${#jq_sub_names[@]} != 0 ];then
	for ((i=0;i<${#jq_sub_names[@]};i++));do
		if [[ ${jq_sub_names[$i]} != ${project_name} || ${jq_sub_names[$i]} != ${web_module} ]];then
			fun_deploy_nexus "${build_context}" "${master_dir}/${jq_sub_names[$i]}"
		fi
	done
fi

#master_dir进行docker image构建并上传到docker registry
if [ ${web_module} == ${project_name} ];then
	master_web="${master_dir}"
else
	master_web="${master_dir}/${web_module}"
fi
fun_push_image ${master_web}

#------------------------------------------------------------------------------
#生成patch包
#------------------------------------------------------------------------------
#下载last tag并解压到last_dir
last_dir="${WORKSPACE}/last_dir"
mkdir -p ${last_dir}
last_tag_zip_url=$(fun_zip_url ${project_name} ${last_tag})
last_tag_zip_path="${WORKSPACE}/last.zip"
curl -o "${last_tag_zip_path}" "${last_tag_zip_url}"
unzip -q -d "${last_dir}" "${last_tag_zip_path}"
rm -rf ${last_tag_zip_path}
	#找到last_web文件夹
if [ ${web_module} == ${project_name} ];then
	last_web="${last_dir}"
else
	last_web="${last_dir}/${web_module}"
fi
#对last_web进行编译
fun_package_pro ${last_dir}
#------------------------------------------------------------------------------
#对比master与last编译后修改文件
patch_diff_file_list=($(diff -ruaq "${master_web}/target/${web_module}" \
		"${last_web}/target/${web_module}" \
		| grep '^Files' | grep -v '\.git' | awk '{print $2}'))
#对比master编译后有，last编译后last没有的文件
#屏蔽没有后缀的列，认为没有“.”的列为文件夹
patch_add_file_list=($(diff -ruaq "${master_web}/target/${web_module}" \
		"${last_web}/target/${web_module}" \
		| grep '^Only' | grep "${master_dir}" | grep -v '\.git' \
		| awk  '{print $3,$4;}' | sed 's/: /\//'))

#创建patch_dir文件夹
patch_dir="${WORKSPACE}/patch"
patch_name="${module_name}.zip"
mkdir -p ${patch_dir}

#把master_dir的add\diff文件复制到patch_dir
if [[ ${#patch_diff_file_list[@]} != 0 ]];then
	for i in ${!patch_diff_file_list[@]};do
		dir_path="${patch_diff_file_list[$i]/"${master_web}/target"/${patch_dir}}"
		mkdir -p $(dirname "${dir_path}")
		if [ -d ${patch_diff_file_list[$i]} ];then
			continue
		fi
		cp "${patch_diff_file_list[$i]}" "${dir_path}"
	done
fi

if [[ ${#patch_add_file_list[@]} != 0 ]];then
	for i in ${!patch_add_file_list[@]};do
		if [ -d ${patch_add_file_list[$i]} ];then
			dir_path="${patch_add_file_list[$i]/"${master_web}/target"/${patch_dir}}"
			mkdir -p "${dir_path}"
			cp -r "${patch_add_file_list[$i]}" $(dirname "${dir_path}")
		else
			dir_path="${patch_add_file_list[$i]/"${master_web}/target"/${patch_dir}}"
			mkdir -p $(dirname "${dir_path}")
			cp "${patch_add_file_list[$i]}" "${dir_path}"
		fi
	done
fi

#对比master_dir编译后有，last_dir编译后master_dir没有的文件
#屏蔽没有后缀的列，认为没有“.”的列为文件夹
patch_remove_file_list=($(diff -ruaq "${master_web}/target/${web_module}" \
									"${last_web}/target/${web_module}" \
									| grep '^Only' | grep "${last_web}" \
									| awk  '{print $3,$4;}' | sed 's/: /\//'  \
									| sed "s;"${last_web}/target/${web_module}/";;"))

if [[ ${#patch_remove_file_list[@]} != 0 ]];then
	for i in ${!patch_remove_file_list[@]};do
		fun_superadd_script "rm -rf ${patch_remove_file_list[i]}"
	done
fi

mv "${WORKSPACE}/remove_file.sh" "${patch_dir}/${web_module}"

#压缩patch_dir
cd "${patch_dir}"
zip -r "${WORKSPACE}/${web_module}.zip" ./
#压缩增量包并上传（scp）到指定服务器备份
fun_backup_file "${WORKSPACE}/${web_module}.zip"
#删除编译后文件
rm -rf $(find ${WORKSPACE} -name '*\.jar')
rm -rf $(find ${WORKSPACE} -name '*\.war')
;;
'full')
#------------------------------------------------------------------------------
cd ${base_dir}

#循环遍历最外层dependencies数组，修改父pom外部依赖
for ((i=0;i<${#jq_dependencies[@]};i++));do
	jq_dependency=$(echo ${jq_dependencies[${i}]} | jq "fromjson")
	jq_dependency_length=$(echo ${jq_dependency} | jq length)
	#判断dependency数组是否为空
	if [ ${jq_dependency_length} > 0 ];then
		#循环遍历dependency数组
		for ((j=0;j<${jq_dependency_length};j++));do
			#判断dependency数组是否有子项目
			if [[ $(echo ${jq_dependency} | jq ".[${j}] | .modules") && \
				$(echo ${jq_dependency} | jq ".[${j}] | .modules") != "null" ]];then
				#获取参数
				jq_sub_names=($(echo ${jq_dependency} \
					| jq ".[${j}] | .modules | .[] | .name" | sed {s/\"//g}))
				jq_sub_values=($(echo ${jq_dependency} \
					| jq ".[${j}] | .modules | .[] | .version" | sed {s/\"//g}))
				#获取依赖并修改pom版本号
				if [ ${#jq_sub_names[@]} != 0 ];then
					for ((k=0;k<${#jq_sub_names[@]};k++));do
						fun_dependency_change "${build_context}" "${base_dir}" \
							"${jq_sub_names[$k]}" "${jq_sub_values[$k]}"
					done
				fi
			fi
		done
	fi
done

#修改父pom版本号
fun_version_change "${build_context}" "${base_dir}"

#获取参数
jq_sub_names=($(echo ${json_description} | jq '.modules | .[] | .name' | sed {s/\"//g}))

#修改子项目pom版本号
if [ ${#jq_sub_names[@]} != 0 ];then
	for ((i=0;i<${#jq_sub_names[@]};i++));do
		if [[ ${jq_sub_names[$i]} != ${project_name} || ${jq_sub_names[$i]} != ${web_module} ]];then
			fun_version_change "${build_context}" "${base_dir}/${jq_sub_names[$i]}" 
		fi
	done
fi

#父项目编译打包并上传到nexus
fun_deploy_nexus "${build_context}" "${base_dir}"

#子项目编译打包并上传到nexus
if [ ${#jq_sub_names[@]} != 0 ];then
	for ((i=0;i<${#jq_sub_names[@]};i++));do
		if [[ ${jq_sub_names[$i]} != ${project_name} || ${jq_sub_names[$i]} != ${web_module} ]];then
			fun_deploy_nexus "${build_context}" "${base_dir}/${jq_sub_names[$i]}" 
		fi
	done
fi

#base_dir进行docker image构建并上传
if [ ${web_module} == ${project_name} ];then
	base_web="${base_dir}"
else
	base_web="${base_dir}/${web_module}"
fi
fun_push_image ${base_web}

#删除编译后文件
rm -rf $(find ./ -name '*\.war'| grep "docker")
war_path=$(find ./ -name '*\.war' | head -n 1)

#压缩增量包并上传（scp）到指定服务器备份
fun_backup_file "${war_path}"
;;
esac