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
