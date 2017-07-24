* * *

cloud-config.properties文件中添加：
```propteries
+ #piculus
+ piculus.server.url=tcp://192.168.1.82:61616 #根据实际使用配置
+ piculus.username=admin #根据实际使用配置
+ piculus.password=admin #根据实际使用配置
+ piculus.sysCode=${sysCode}

```

* * *

parent pom.xml文件中添加：
```xml
<properties>
+    <piculus-client.version>[1.0.0-SNAPSHOT]</piculus-client.version> #根据实际使用配置
</properties>
    
<dependencyManagement>
    <dependencies>
+        <dependency>
+            <groupId>com.joinwe</groupId>
+            <artifactId>piculus-client</artifactId>
+            <version>${piculus-client.version}</version>
+        </dependency>
    </dependencies>
</dependencyManagement>
```
* * *

web/cliud pom.xml文件中添加：
```xml
<dependencies>
+    <!-- piculus -->
+    <dependency>
+        <groupId>com.joinwe</groupId>
+        <artifactId>piculus-client</artifactId>
+    </dependency>
</dependencies>
```
* * *

Application.java文件中添加:
```java
- @ComponentScan(basePackages = { "com.joinwe.pbap.*", "com.joinwe.bssp.api.*", "com.joinwe.common.*" })

+ @ComponentScan(basePackages = { "com.joinwe.pbap.*", "com.joinwe.bssp.api.*", "com.joinwe.common.*","com.joinwe.piculus.*" })
```
* * *

spring-db.xml文件中添加：
```xml
- <bean name="mapperScannerConfigurer" class="org.mybatis.spring.mapper.MapperScannerConfigurer">
-		<property name="basePackage" value="com.joinwe.pbap.dao;com.joinwe.bssp.dao;com.joinwe.bacs.dao" />
-		<property name="sqlSessionFactoryBeanName" value="sqlSessionFactory" />
-  </bean>

+ <bean name="mapperScannerConfigurer" class="org.mybatis.spring.mapper.MapperScannerConfigurer">
+		<property name="basePackage" value="com.joinwe.pbap.dao;com.joinwe.bssp.dao;com.joinwe.bacs.dao;com.joinwe.pbap.piculus.dao" />
+		<property name="sqlSessionFactoryBeanName" value="sqlSessionFactory" />
+ </bean>
```
* * *

com.joinwe.pbap.piculus
    CollectErrorManagerImpl.java
    FixTradeManagerImpl.java
com.joinwe.pbap.piculus.collect
    collect/AbstractCollectService.java
    collect/InterRechargeCollectServiceImpl.java
    collect/InterWithdrawAccCollectServiceImpl.java
    collect/InterWithdrawCollectServiceImpl.java
    collect/RechargeFailedCollectServiceImpl.java
    collect/RechargeTimeoutCollectServiceImpl.java
    collect/WithdrawFailedAccCollectServiceImpl.java
    collect/WithdrawFailedCollectServiceImpl.java
    collect/WithdrawTimeoutCollectServiceImpl.java
com.joinwe.pbap.piculus.dao
    dao/AccTradeDao.java
com.joinwe.pbap.piculus.entity
    entity/TradeData.java
    entity/TradeResp.java
com.joinwe.pbap.piculus.exception
    exception/DataInvalidFixException.java
    exception/FailedException.java
    exception/FixException.java
    exception/InterFailedException.java
    exception/NotInterException.java
    exception/RepeatFixException.java
    exception/TradeFailedException.java
    exception/VerifyFailedFixException.java
com.joinwe.pbap.piculus.fix
    fix/AbstractFixTradeService.java
    fix/InterRechargeFixServiceImpl.java
    fix/InterWithdrawAccFixServiceImpl.java
    fix/InterWithdrawFixServiceImpl.java
    fix/RechargeFailedFixServiceImpl.java
    fix/RechargeTimeoutFixServiceImpl.java
    fix/WithdrawFailedAccFixServiceImpl.java
    fix/WithdrawFailedFixServiceImpl.java
    fix/WithdrawTimeoutFixServiceImpl.java
com.joinwe.pbap.piculus.query
    query/AccTradeQuery.java
    query/TradeQuery.java
com.joinwe.pbap.piculus.service
    service/MQInterTradeService.java
    service/MQInterTradeServiceImpl.java
    service/PnrTradeService.java
    service/PnrTradeServiceImpl.java
com.joinwe.pbap.piculus.support
    support/GenerateNumUtil.java
    support/ServiceMessageBuilder.java
