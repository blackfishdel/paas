# Bug: Return value of java.math.BigDecimal.setScale(int, int) ignored in com.kubao.shouyou.common.utils.base.BigDecimalUtils.bigDecimalToString(BigDecimal)

```java
  public static String bigDecimalToString(BigDecimal value){
    if(value != null){
      value.setScale(2,DEFAULT_ROUND);
      return value.toString();
    }
    return null;
  }
```

# Bug: Dead store to pcUserName rather than field with same name in com.kubao.shouyou.common.context.request.SyBaseRequest.setPcUserName(String)

```java
  public void setPcUserName(String pcUserName) {
      pcUserName = pcUserName;
  }
```

# Bug: Format-string method String.format(String, Object[]) called with format string "{}的父类非泛型类" wants 0 arguments but is given 1 in com.kubao.shouyou.common.utils.base.GenericsUtils.getSuperClassGenricType(Class, int)

```java
 public static Class getSuperClassGenricType(Class clazz, int index) {
     Type genType = clazz.getGenericSuperclass();
     if (!(genType instanceof ParameterizedType)) {
         LogUtils.logWarn(String.format("{}的父类非泛型类", clazz.getSimpleName()));
         return Object.class;
     }
     Type[] params = ((ParameterizedType) genType).getActualTypeArguments();
     if (index >= params.length || index < 0) {
         LogUtils.logWarn(String.format("索引: {} 超出了  {} 的泛型参数长度:{}", new Object[]{index, clazz.getSimpleName(), params.length}));
         return Object.class;
     }
     if (!(params[index] instanceof Class)) {
         LogUtils.logWarn(String.format("{} 在父类的泛型参数中不是真正的Class类型", clazz.getSimpleName()));
         return Object.class;
     }
     return (Class) params[index];
 }
```

# Bug: Synchronization performed on java.util.concurrent.ConcurrentHashMap in com.kubao.shouyou.common.utils.Singleton.getSingleton(Class)

此方法执行的同步对象，从java.util.concurrent包的一个类的实例（或它的子类）。这些类的实例有自己的并发控制机制，对同步的java关键字提供同步正交。例如，同步对AtomicBoolean不会阻止其他线程修改AtomicBoolean。

```java
  public static<T> T getSingleton(Class<T> type){
      T ob = (T)map.get(type);
      try {
           if(ob==null){
               synchronized (map){
                   ob= type.newInstance();
                   map.put(type,ob);
               }
           }
      } catch (InstantiationException e) {
          e.printStackTrace();
          LogUtils.logDebug(e.getMessage());
      } catch (IllegalAccessException e) {
          e.printStackTrace();
          LogUtils.logDebug(e.getMessage());
      }
      return ob;
  }
```

# Bug: Invocation of toString on Throwable.getStackTrace() in com.kubao.shouyou.common.exception.BaseException.getExceptionStackMsg()

该代码调用toString()，这将产生一个无用的结果，如[C@16f0472. 考虑使用Arrays.toString方法将数组转换为可读的字符串。

```java
  public String getExceptionStackMsg() {
      if (this.t != null) {
          return this.t.getStackTrace().toString();
      } else {
          return this.exceptionStackMsg != null ? this.exceptionStackMsg : null;
      }
  }
```


# Bug: BigDecimal constructed from 1.3 in com.kubao.shouyou.service.impl.GoodsSearchServiceImpl.getGuessLikePrice(ReqGuessLike)

此代码创建一个BigDecimal，翻译不好一个十进制数的double类型。例如，有人可能会认为写新的BigDecimal(0.1)在java创建一个BigDecimal，等于0.1（有1个刻度的1，一个不成比例的价值），但它实际上是等于0.1000000000000000055511151231257827021181583404541015625。你可能想使用BigDecimal.valueOf(double d)的方法，即用双的字符串表示形式创建BigDecimal(例如，BigDecimal.valueOf(0.1) 为 0.1)。

new BigDecimal(1.2) 改为 new BigDecimal(”1.2“)

```java
  private ReqGuessLike getGuessLikePrice(ReqGuessLike reqGuessLike){
      BigDecimal price = reqGuessLike.getPrice();

      if (price.compareTo(new BigDecimal(1000)) >= 0) {
          reqGuessLike.setSearchMinPrice(new BigDecimal(1000));
          reqGuessLike.setSearchMaxPrice(new BigDecimal(99999999));
          return reqGuessLike;
      }
      if (price.compareTo(new BigDecimal(500)) >= 0) {
          reqGuessLike.setSearchMinPrice(price);
          reqGuessLike.setSearchMaxPrice(price.multiply(new BigDecimal(1.2)));
          return reqGuessLike;
      }
      if (price.compareTo(new BigDecimal(300)) >= 0) {
          reqGuessLike.setSearchMinPrice(price);
          reqGuessLike.setSearchMaxPrice(price.multiply(new BigDecimal(1.3)));
          return reqGuessLike;
      }
      if (price.compareTo(new BigDecimal(100)) >= 0) {
          reqGuessLike.setSearchMinPrice(price);
          reqGuessLike.setSearchMaxPrice(price.multiply(new BigDecimal(1.5)));
          return reqGuessLike;
      }
      if (price.compareTo(new BigDecimal(50)) >= 0) {
          reqGuessLike.setSearchMinPrice(new BigDecimal(100));
          reqGuessLike.setSearchMaxPrice(new BigDecimal(200));
          return reqGuessLike;
      }
      if (price.compareTo(new BigDecimal(0)) >= 0) {
          reqGuessLike.setSearchMinPrice(new BigDecimal(0));
          reqGuessLike.setSearchMaxPrice(new BigDecimal(100));
          return reqGuessLike;
      }

      return reqGuessLike;
  }
```
