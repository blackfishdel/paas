
# super-bom打包上传到nexus服务器
#
#
#
cd /Users/xiepeng/Documents/GitHub/super-bom && \
mvn clean install deploy -U -Dmaven.test.skip=true \
-DaltSnapshotDeploymentRepository="m5173::default::http://61.130.29.7/nexus/content/repositories/snapshots/"

cd /Users/xiepeng/Documents/GitHub/super-bom && \
mvn deploy -U -Dmaven.test.skip=true \
-DaltReleaseDeploymentRepository="m5173::default::http://61.130.29.7/nexus/content/repositories/snapshots/"

cd /Users/xiepeng/Documents/GitHub/base-project
cd ./sso-service && \
mvn clean install -U -Dmaven.test.skip=true && \
cd ./sso-support-service && \
mvn docker:build -DpushImage


docker tag davidcaste/alpine-tomcat:jre8tomcat8 192.168.140.90:5000/alpine-tomcat:jre8tomcat8
docker push 192.168.140.90:5000/alpine-tomcat:jre8tomcat8
