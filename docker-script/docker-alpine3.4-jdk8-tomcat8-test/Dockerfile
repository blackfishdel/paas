# 基础镜像为公有镜像
FROM zkpregistry.com:5043/alpine-tomcat:jdk8tomcat7
MAINTAINER del xie

COPY server.xml ${TOMCAT_HOME}/conf/server.xml

#将工程WAR包加到webapps目录，并命名为ROOT.war
ADD /ROOT ${TOMCAT_HOME}/webapps/ROOT
CMD ["/opt/tomcat/bin/catalina.sh","run"]