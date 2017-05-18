#Spring Boot 1.5发行说明

##spring-boot1.5弃用的功能
* TomcatEmbeddedServletContainerFactory.setTldSkip已被弃用
* ApplicationStartedEvent 已被替换 ApplicationStartingEvent
* 几个常数LoggingApplicationListener已被替换为版本LogFile
* 由于Guava支持将在Spring Framework 5中删除，所以使用Guava缓存已被弃用。升级到Caffeine
* 不再主动维护CRaSH支持
* 引入之后，EndpointMBeanExporter已经弃用了几种受保护的方法`JmxEndpoint`
* `SearchStrategy.PARENTS`已被替换`SearchStrategy.ANCESTORS`
* Apache DBCP支持已被弃用，有利于DBCP 2
* `server.undertow.buffers-per-region`属性已被弃用，因为它不被使用
* `server.max-http-post-size`属性已被技术特定的变体所替代（例如`server.tomcat.max-http-post-size`）
* 该`spring.data.neo4j.session.scope`已被移除

##spring-boot1.4弃用的功能
在此版本中已经删除了在Spring Boot 1.4中不推荐使用的类，方法和属性。请确保您在升级之前不调用不建议使用的方法。特别地，`HornetQ`和`Velocity`支持已被删除

###重命名starter包
* spring-boot-starter-ws → spring-boot-starter-web-services
* spring-boot-starter-redis → spring-boot-starter-data-redis

###@ConfigurationProperties注解修改
如果您有@ConfigurationProperties使用JSR-303约束注释的类，那么您现在应该另外使用它们进行注释`@Validated`。目前的验证工作目前仍将继续工作，但是会发出警告。在未来，类没有@Validated不会被验证。

###Spring Session store
以前，如果您没有特别配置的Spring Session和Redis，Redis会自动用于存储session。您现在需要指定存储类型; 使用Redis的Spring Session的现有用户应在其配置中添加以下内容：
```prop
spring.session.store-type = redis
```

###Actuator安全
执行器“sensitive”端点默认情况下是安全的（即使不依赖于“Spring Security”）。如果您现有的Spring Boot 1.4应用程序使用了Spring Security（并且没有任何自定义安全配置），那么应该像以前那样工作。如果您现有的Spring Boot 1.4应用程序具有自定义的安全配置，并且希望对sensitive端点有开放的访问权限，则需要在安全配置中显式配置它。如果您正在升级不符合Spring Security的Spring Boot 1.4应用程序，并且希望保留对sensitive端点的开放访问权限，则需要设置management.security.enabled该应用程序false。有关更多详细信息，请参阅更新的参考文档。

访问端点所需的默认角色也从更改`ADMIN`为`ACTUATOR`。这是为了防止端点的意外暴露，如果您恰好将ADMIN角色用于其他目的。如果要恢复Spring Boot 1.4的行为设置management.security.roles属性为ADMIN。

###InMemoryMetricRepository
将`InMemoryMetricRepository`不再直接实现`MultiMetricRepository`。`InMemoryMultiMetricRepository`现在已经注册了一个满足`MultiMetricRepository`接口并由常规支持的新bean `InMemoryMetricRepository`。由于大多数用户将与`MetricRepository`或`MultiMetricRepository`接口进行交互（而不是内存中的实现），因此此更改应该是透明的。

###spring.jpa.database
在`spring.jpa.database`现在能够自动检测从共同数据库`spring.datasource.url`属性。如果您已手动定义`spring.jpa.database`，并且使用公用数据库，则可能需要尝试完全删除该属性。

几个数据库有多个数据库Dialect（例如，Microsoft SQL Server有3个），因此我们可能会配置一个与您正在使用的数据库版本不匹配的数据库。如果你以前有一个工作的设置，并希望依靠Hibernate自动检测Dialect，设置`spring.jpa.database=default`。或者，您可以随时使用该`spring.jpa.database-platform`属性设置方言。

###@IntegrationComponentScan
Spring Integration的`@IntegrationComponentScan`注释现在是自动配置的。如果您遵循推荐的项目结构，您应该尝试删除它。

###ApplicationStartedEvent
如果你现在正在监听ApplicationStartedEvent，你应该重构使用`ApplicationStartingEvent`。我们更名为这个class，以更准确地反映它的作用。

###JSP servlet
默认情况下，JSP servlet不再处于开发模式。开发模式在使用DevTools时自动启用。它也可以通过设置显式启用`server.jsp-servlet.init-parameters.development=true`。

###忽略的路径和 @EnableWebSecurity
在Spring Boot 1.4和更早版本中，执行器将始终配置一些忽略的路径，而不管使用何种方式`@EnableWebSecurity`。这已在1.5中得到纠正，因此使用@EnableWebSecurity将关闭所有Web安全的自动配置，从而允许您完全控制。

###事务管理器属性
现在可以配置PlatformTransactionManager使用spring.transaction.\*属性自动配置的各个方面。目前支持“default-timeout”和rollback-on-commit-failure属性。
