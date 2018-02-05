
# super-bom打包上传到nexus服务器
#
#
#
# snapshot
cd /Users/xiepeng/Documents/GitHub/super-bom && \
mvn clean install deploy -U -Dmaven.test.skip=true \
-DaltSnapshotDeploymentRepository="m5173::default::http://61.130.29.7/nexus/content/repositories/snapshots/"


# release
cd /Users/xiepeng/Documents/GitHub/super-bom && \
mvn deploy -U -Dmaven.test.skip=true \
-DaltReleaseDeploymentRepository="m5173::default::http://61.130.29.7/nexus/content/repositories/release/"

# 显示引用jar包为什么被使用
mvn dependency:tree -Dverbose -Dincludes=aspectjweaver

mvn clean install  && \
cd ./sso-support-starter && \
mvn deploy -U -Dmaven.test.skip=true \
-DaltSnapshotDeploymentRepository="m5173::default::http://61.130.29.7/nexus/content/repositories/snapshots/"

cd ./sso-service && \
mvn clean install -U -Dmaven.test.skip=true && \
cd ./sso-support-service && \
mvn docker:build -DpushImage
192.168.140.90:5000/sso-support-service:0.0.1-SNAPSHOT

docker tag davidcaste/alpine-tomcat:jre8tomcat8 192.168.140.90:5000/alpine-tomcat:jre8tomcat8
docker push 192.168.140.90:5000/alpine-tomcat:jre8tomcat8
