在本节中，您将学习如何创建基本的 测试计划来测试数据库服务器。您将创建50个向数据库服务器发送2个SQL请求的用户。另外，你会告诉用户运行100次测试。因此，请求总数是（50个用户）x（2个请求）x（重复100次）= 10'000个JDBC请求。要构建测试计划，您将使用以下元素： 线程组， JDBC请求，摘要报告。


> 本示例使用MySQL数据库驱动程序。要使用此驱动程序，必须将其包含.jar文件（例如mysql-connector-java-XXX-bin.jar）复制到JMeter ./lib目录（ 有关更多详细信息，请参阅JMeter的[Classpath](http://jmeter.apache.org/usermanual/get-started.html#classpath)）。

## 1添加用户

您想要对每个JMeter测试计划执行的第一步是添加一个 线程组元素。线程组告诉JMeter您想要模拟的用户数量，用户应该多长时间发送请求以及他们应该发送多少个请求。

继续添加ThreadGroup元素，方法是首先选择Test Plan，单击鼠标右键以获取Add菜单，然后选择 Add  →  ThreadGroup。

您现在应该看到测试计划下的线程组元素。如果您没有看到该元素，则通过单击测试计划元素来“展开”测试计划树。

接下来，您需要修改默认属性。如果您尚未选择它，请选择树中的线程组元素。您现在应该看到JMeter窗口右侧的线程组控制面板（请参见下面的图6.1）

![图6.1](http://jmeter.apache.org/images/screenshots/jdbctest/threadgroup1.png)图6.1 带有默认值的线程组

首先为我们的线程组提供更具描述性的名称。在名称字段中，输入JDBC用户。

> 您将需要有效的数据库，数据库表和对该表的用户级访问权限。在此处显示的示例中，数据库为“云”，表名为“vm_instance”。

接下来，将用户数量增加到50。

在下一个字段中，Ramp-Up Period，保留10秒的值。此属性告诉JMeter在启动每个用户之间要延迟多久。例如，如果输入一个10秒的渐进周期，JMeter将在10秒结束时完成所有用户的启动。因此，如果我们有50个用户和10秒的Ramp-Up Period，则启动用户之间的延迟为200毫秒（10秒/ 50个用户=每秒0.2个用户）。如果将该值设置为0，则JMeter将立即启动所有用户。

最后，在循环计数字段中输入值100。该属性告诉JMeter重复测试多少次。要让JMeter反复运行测试计划，请选择Forever复选框。

>在大多数应用程序中，您必须手动接受您在控制面板中所做的更改。但是，在JMeter中，控制面板自动接受您所做的更改。如果更改元素的名称，则在离开控制面板后（例如，选择其他树元素时），树会使用新文本进行更新。

完成的JDBC用户线程组请参见图6.2:
![图6.2](http://jmeter.apache.org/images/screenshots/jdbctest/threadgroup2.png)图6.2 JDBC用户线程组

## 2添加JDBC请求
现在我们已经定义了我们的用户，现在是时候定义他们将要执行的任务。在本节中，您将指定要执行的JDBC请求。

首先选择JDBC用户元素。单击鼠标右键以获取“ 添加”菜单，然后选择添加  →  配置元素  →  JDBC连接配置。然后，选择这个新元素来查看它的控制面板（见图6.3）。

![图6.3](http://jmeter.apache.org/images/screenshots/jdbctest/jdbc-config.png)图6.3 JDBC配置

设置以下字段（这些假设我们将使用名为'云'的MySQL数据库）：

* 变量名称（在这里：myDatabase）绑定到池。这需要唯一标识配置。它由JDBC采样器用来标识要使用的配置。
* 数据库URL：jdbc：mysql：// ipOfTheServer：3306 / cloud
* JDBC驱动程序类：com.mysql.jdbc.Driver
* 用户名：数据库的用户名
* 密码：用户名的密码

屏幕上的其他字段可以保留为默认值。

JMeter使用控制面板中指定的配置设置创建数据库连接池。该池在“变量名称”字段中的JDBC请求中引用。可以使用几个不同的JDBC配置元素，但它们必须具有唯一的名称。每个JDBC请求都必须引用一个JDBC配置池。多个JDBC请求可以引用同一个池。

再次选择JDBC用户元素。单击鼠标右键以获取添加菜单，然后选择添加  →  采样器  →  JDBC请求。然后，选择这个新元素来查看它的控制面板（见图6.4）。

![图6.4](http://jmeter.apache.org/images/screenshots/jdbctest/JDBCRequest.png)图6.4 JDBC请求

在我们的测试计划中，我们将提出两个JDBC请求。第一个是选择所有'正在运行'的VM实例，第二个是选择'Expunging'虚拟机实例（显然你应该将这些改为适合你的特定数据库的例子）。这些如下所示:

> JMeter按照将它们添加到树的顺序发送请求。

首先编辑以下属性（参见图6.5）：

* 将名称更改为'VM正在运行'。
* 输入池名称：'myDatabase'（与配置元素中的相同）
* 输入SQL查询字符串字段。
* 使用'运行'值输入参数值字段。
* 使用'VARCHAR'输入参数类型。

![图6.5](http://jmeter.apache.org/images/screenshots/jdbctest/JDBCRequest2.png)图6.5 JDBC请求第一个SQL请求

接下来，添加第二个JDBC请求并编辑以下属性（请参见图6.6）：

* 将名称更改为'VM Expunging'。
* 将参数值的值更改为'Expunging'。

![图6.6](http://jmeter.apache.org/images/screenshots/jdbctest/JDBCRequest3.png)图6.6 JDBC请求第二个请求

## 3添加一个监听器来查看/存储测试结果

您需要添加到测试计划的最后一个元素是一个 监听器。该元素负责将您的JDBC请求的所有结果存储在文件中并显示结果。

选择JDBC用户元素并添加摘要报告 监听器（添加  →  监听器  →  汇总报告）。

保存测试计划，然后使用菜单Run  →  Start或 Ctrl  +  R运行测试

听众显示结果。

![图6.7](http://jmeter.apache.org/images/screenshots/jdbctest/jdbc-results.png)图6.7 图表结果监听器
