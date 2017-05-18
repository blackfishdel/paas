# spring容器优雅关闭(spring container graceful shutdown)

##背景
在Linux上通常会通过kill -9 pid的方式强制将某个进程杀掉，这种方式简单高效，因此很多程序的停止脚本经常会选择使用kill -9 pid的方式。
无论是Linux的Kill -9 pid还是windows的taskkill /f /pid强制进程退出,都会带来一些副作用：对应用软件而言其效果等同于突然掉电，可能会导致如下一些问题：
1. 缓存中的数据尚未持久化到磁盘中，导致数据丢失；
1. 正在进行文件的write操作，没有更新完成，突然退出，导致文件损坏；
1. 线程的消息队列中尚有接收到的请求消息还没来得及处理，导致请求消息丢失；
1. 数据库操作已经完成，例如账户余额更新，准备返回应答消息给客户端时，消息尚在通信线程的发送队列中排队等待发送，进程强制退出导致应答消息没有返回给客户端，客户端发起超时重试，会带来重复更新问题；
1. 其它问题等...

##如何优雅关闭
1. 确保Spring-boot项目在Docker 是PID=1 主进程运行
2. `docker stop --time=100 cntainer_name`命令来进行优雅关闭(Eureka服务下线),释放/清理资源使用@PreDestroy注解


###spring请求关闭
每个都`SpringApplication`将注册一个关闭钩子与JVM，以确保`ApplicationContext`在退出时正常关闭。可以使用所有标准的Spring生命周期回调（如`DisposableBean`接口或`@PreDestroy`注释）。此外，org.springframework.boot.ExitCodeGenerator 如果bean希望在应用程序结束时返回特定的退出代码，Bean可以实现该接口。

###启动与关闭的回调方法(startup and shutdown callbacks)
`Lifecycle`接口定义了所有对象的生命周期必要的方法(例如开始和关闭某些`后台进程`):

```java
public interface Lifecycle {
    void start();
    void stop();
    boolean isRunning();
}
```

任何Spring管理的对象都可以实现该接口。然后，当`ApplicationContext`自身接收到启动和停止信号时，例如在tomcat运行时停止/重新起动情况，它会将这些调用级联到`Lifecycle`在该上下文中定义的所有实现。它通过委托给一个`LifecycleProcessor`：
```java
public interface LifecycleProcessor extends Lifecycle {
    void onRefresh();
    void onClose();
}
```

请注意，`LifecycleProcessor`它本身是Lifecycle接口的扩展。它还增加了另外两种方法来对正在刷新和关闭的上下文进行处理。

>请注意，常规`org.springframework.context.Lifecycle`只是显式启动/停止通知的简单通知，并不意味着在上下文刷新时自动启动(如果只是对springContext进行刷新重启的话并不会运行`Lifecycle`的对象方法)。考虑实现`org.springframework.context.SmartLifecycle`对特定对象（包括启动阶段）的自动启动的细粒度控制。此外，请注意，停止通知不能保证在销毁之前：在定期关闭时，所有继承`Lifecycle`的对象将在广泛的销毁回调正在传播之前首先收到停止通知。无论如何在上下文生命周期的热刷新或中止刷新时，只会调用destroy方法。

启动和关闭调用的顺序很重要。如果任何两个对象之间存在“依赖"关系，则依赖方将在其依赖关系之后启动，并在其依赖之前停止。然而，有时直接依赖是未知的。您可能只知道某种类型的对象应该在另一种类型的对象之前开始。在这种情况下，`SmartLifecycle`接口定义了另一个选项，即`getPhase()`其超级接口`Phased`上定义的方法。

```java
public interface Phased {
    int getPhase();
}
```

```java
public interface SmartLifecycle extends Lifecycle, Phased {
    boolean isAutoStartup();
    void stop(Runnable callback);
}
```
>start order:min-->max
>
>stop order:max-->min

当启动时，phase值最低的oject首先启动，停止时按照相反的顺序进行。因此，实现`SmartLifecycle`的`getPhase()`方法及其方法返回`Integer.MIN_VALUE`将是`第一个开始，最后一个停止`。在这个范围的另一端，phase值`Integer.MAX_VALUE`将指示对象应该首先被启动并停止（可能是因为它依赖于其他进程要运行）。当考虑相位值时，同样重要的是要知道，任何不实现的“正常"`Lifecycle`对象的默认阶段`SmartLifecycle`都将为0。因此，任何负phase值都表示一个对象应在这些标准组件之前开始他们），反之亦然，任何正phase值。

正如您所看到的，SmartLifecycle定义的stop()方法接受一个回调。任何实现都必须调用那个回调的run()方法，在该实现的关闭过程完成之后。在必要时,使异步关闭自`LifecycleProcessor`接口的默认实现`DefaultLifecycleProcessor`,将其超时值等待对象的组在每个阶段调用回调。默认的每个阶段超时是30秒。您可以覆盖默认的生命周期处理器实例通过定义一个名为“lifecycleProcessor"上下文中的bean。如果您只想修改超时，那么定义以下内容就足够了:

```xml
<bean id=“lifecycleProcessor"  class=“org.springframework.context.support.DefaultLifecycleProcessor" >
    <!-- 以毫秒为单位的超时值 -->
    <property name=“timeoutPerShutdownPhase"  value=“10000" />
</bean>
```
