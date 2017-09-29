# 
---

## 目录
[TOC]


---

### 数据库事务管理
---
请在spring数据库配置文件
e.g:
> spring-db.xml

添加配置:
```xml
<beans>
...
	<bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <property name="dataSource" ref="proxyDataSource" />
        <property name="configLocation" value="classpath:/mybatis.xml" />
        <property name="mapperLocations" value="classpath*:/mappers/**/*.xml" /><!-- 扫描 xml -->
    </bean>

    <bean name="mapperScannerConfigurer" class="org.mybatis.spring.mapper.MapperScannerConfigurer">
        <property name="basePackage" value="...;com.joinwe.pbap.mq.dao" /><!-- 扫描mapper bean -->
        <property name="sqlSessionFactoryBeanName" value="sqlSessionFactory" />
    </bean>

    <!-- mq aop事务 -->
    <tx:advice id="mqTransactionAdvice" transaction-manager="txManager">
        <tx:attributes>
            <tx:method name="fix*" propagation="REQUIRED" rollback-for="Exception" /><!-- 扫描fix方法 -->
            <tx:method name="*" propagation="SUPPORTS" read-only="true" />
        </tx:attributes>
    </tx:advice>
    <aop:config>
        <aop:pointcut id="mqServicesPointcut" expression="execution(* com.joninwe.**.mq.*Impl.*(..))" /><!-- 扫描service -->
        <aop:advisor advice-ref="mqTransactionAdvice" pointcut-ref="servicesPointcut" />
    </aop:config>
...
</beans>
```