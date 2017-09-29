#/bin/bash

mkdir ./keystroe
cd keystroe
/home/delxie/Documents/jdk1.7.0_80/bin/keytool -genkey -alias tomcat -keyalg RSA

/home/delxie/Documents/jdk1.7.0_80/bin/keytool -export -alias tomcat -file server.crt

/home/delxie/Documents/jdk1.7.0_80/bin/keytool -certreq -keyalg RSA -alias tomcat -file certreq.csr -keystore .keystore
