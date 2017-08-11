FROM davidcaste/alpine-java-unlimited-jce:jdk8

ENV TOMCAT_MAJOR=7 \
    TOMCAT_VERSION=7.0.77 \
    TOMCAT_HOME=/opt/tomcat \
    CATALINA_HOME=/opt/tomcat \
    CATALINA_OUT=/dev/null

RUN apk upgrade --update && \
    apk add --update curl && \
    curl -jksSL -o /tmp/apache-tomcat.tar.gz http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    gunzip /tmp/apache-tomcat.tar.gz && \
    tar -C /opt -xf /tmp/apache-tomcat.tar && \
    ln -s /opt/apache-tomcat-${TOMCAT_VERSION} ${TOMCAT_HOME} && \
    rm -rf ${TOMCAT_HOME}/webapps/* && \
    apk del curl && \
    rm -rf /tmp/* /var/cache/apk/*

COPY logging.properties ${TOMCAT_HOME}/conf/logging.properties
COPY server.xml ${TOMCAT_HOME}/conf/server.xml
COPY catalina.properties ${TOMCAT_HOME}/conf/catalina.properties

#VOLUME ["/logs","/dockerv/private/tomcatlogs"]
VOLUME ["/dev/urandom","/dev/random"]

#创建日志目录链接
RUN mkdir /logs && \
		mkdir -p /dockerv/private && \
		ln -s /logs /dockerv/private/tomcatlogs
EXPOSE 8080

#安装tzdata安装包
RUN apk add --no-cache tzdata 
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
		echo $TZ > /etc/timezone
