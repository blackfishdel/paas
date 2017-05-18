# spring对象生命周期销毁

## 对象生命周期的回调方法(Lifecycle callbacks)
spring要与容器内对象的生命周期管理进行控制，可以实现spring `InitializingBean`和`DisposableBean`接口。容器对象进行初始化和销毁时调用`afterPropertiesSet()`和`destroy()`方法对执行某些操作。

>`@PostConstruct`和`@PreDestroy`注释被认为是spring应用程序管理对象生命周期的最佳实践。使用这些注释意味着bean不与Spring`特定的接口耦合`。如果仍然希望删除耦合，考虑在xml文件中定义对象元数据中使用`init-method`和`destroy-method`。

在容器内，spring使用`BeanPostProcessor`来实现可以在对象中找到的任何callbacks接口。如果需要自定义功能或者其他的生命周期行为，spring不提供该功能，可以自己实现`BeanPostProcessor`这个接口。

除了初始化和销毁​​callbacks之外，Spring管理的对象还可以实现`Lifecycle`接口，以便这些对象可以由容器自己的生命周期驱动启动和关闭进程。

## 对象生命周期的销毁回调方法(Destruction callbacks)
1. 使用基于Scan的配置元数据,使用@PreDestroy注释或指定由bean定义支持的通用方法：
```java
@component
public class ExampleBean{
  @PreDestroy
  void cleanup(){
    //做一些关闭工作(比如释放线程池连接)
  }
}
```

2. 使用基于XML的配置元数据，可以使用<bean/>元素的`destroy-method`属性:
```xml
<bean id=“exampleInitBean” class=“examples.ExampleBean” destroy-method=“cleanup” />
```
```java
public class ExampleBean{

  void cleanup(){
    //做一些关闭工作(比如释放线程池连接)
  }
}
```

3. 使用基于Java文件配置元数据，可以使用@bean中的`destroyMethod`属性：
```java
public class Bar {
    public void cleanup() {
        // 销毁逻辑代码
    }
}

@Configuration
public class AppConfig {
    @Bean(destroyMethod = "cleanup")
    public Bar bar() {
        return new Bar();
    }
}
```
>默认情况下，使用具有公共close()或shutdown()方法的Java配置定义的对象将自动使用销毁回调方法。如果您有公共 close()或shutdown()方法，并且您不希望在容器关闭时调用它，只需添加@Bean(destroyMethod="")到您的bean定义以禁用默认(inferred)模式。
>
>默认情况下，您可能希望通过JNDI获取的资源，因为其生命周期在应用程序之外进行管理。特别地请确保始终这样做，`DataSource`因为它已知在Java EE应用程序服务器上都会有问题。
```java
@Bean(destroyMethod =“”)
 public DataSource dataSource() throws NamingException {
     return(DataSource)jndiTemplate.lookup( “MyDS”);
}
```
>另外，使用@Bean方法，通常会选择使用编程的JNDI查找：使用Spring的`JndiTemplate`/ `JndiLocatorDelegatehelpers`或直接的JNDI InitialContext使用，而不是`JndiObjectFactoryBean`强制您将返回类型声明为FactoryBean类型而不是实际的目标类型的变体在其他@Bean方法中更难用于交叉引用调用，这些方法将在此引用提供的资源。


4. 实现`org.springframework.beans.factory.DisposableBean`这个接口允许对象在包含它的容器被销毁时执行回调方法。该`DisposableBean`接口指定方法：
```java
void destroy() throws Exception;
```
>注意：`建议不要使用`DisposableBean回调接口，因为它不必要地将代码耦合到Spring。

##对象生命周期的默认的初始化和销毁方法(Default initialization and destroy methods)
当写的初始化和销毁不使用Spring的`InitializingBean`和`DisposableBean`回调接口中的具体方法回调，通常写有如方法init()，initialize()，dispose()，等等的方法。理想情况下，这种生命周期回调方法的名称在整个项目中是标准化的，因此所有开发人员都使用相同的方法名称并确保一致性。

您可以将Spring容器配置`look`为`命名初始化`，并在每个对象上销毁回调方法名称。这意味着作为应用程序开发人员，您可以编写应用程序类并使用调用的初始化回调init()，而无需为init-method="init"每个bean定义配置一个属性。

假设你的初始化回调方法是命名的desotroy()，而且回调方法被命名destroy()。在下面的例子中，类似于下面这class:
```java
public class DefaultBlogService extends BlogService {
    private BlogDao blogDao;
    public void setBlogDao(BlogDao blogDao){
         this .blogDao = blogDao;
    }
    //这是销毁回调方法
    public void destroy{
      // 销毁逻辑代码
    }
}
```

```xml
<beans default-destroy-method="destroy" >
  <bean id="blogService" class="com.foo.DefaultBlogService" >
    <property name="blogDao" ref="blogDao" />
  </bean>
<beans/>
```

在Spring 2.5版本以后，有控制对象的生命周期行为的三个选项：在`InitializingBean`和`DisposableBean`回调接口，自定义init()和destroy()方法和@PostConstruct和@PreDestroy注释。可以组合这些机制来控制对象的生命周期。

销毁方法按相同顺序调用：
* 方法注释`@PreDestroy`
* `destroy()`由`DisposableBean`回调接口定义
* 自定义配置`destroy()`方法
