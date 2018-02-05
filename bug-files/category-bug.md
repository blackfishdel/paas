# Bug: outResults is null guaranteed to be dereferenced in com.m5173.mobile.category.common.utils.JoSqlListUtils.select(List, Class, String, Map) on exception path

```java
public static <T> T select(List<?> targetList, Class clazz, String jqlText, Map queryMap) {
  if (clazz==null || StringUtils.isEmpty(jqlText)) {
    return (T) targetList;
  }
  if (MapUtils.isEmpty(queryMap)) {
    queryMap =new HashMap();
  }
  Query query = new Query();
  QueryResults outResults = null;
  //jqlText = StringUtils.replace(jqlText, JoSqlCons.AOSLIST_KEY, clazz.getName());
  try {
    query.parse(jqlText);
    query.setVariables(queryMap);
    outResults = query.execute(targetList);
  } catch (QueryParseException e) {
    e.printStackTrace();
  } catch (QueryExecutionException e) {
    e.printStackTrace();
  }jqlText = jqlText.replaceAll(" ", "");
  jqlText = StringUtils.upperCase(jqlText);
  if (StringUtils.indexOf(jqlText, "SELECT*FROM") != -1) {
    // 查询的是整个对象，则直接返回
    return (T) outResults.getResults();
  } else {
    // 查询的是部分字段，则josql封装到了list，需要再通过反射进行二次包装后再返回
    List<SelectItemExpression> columnItemList = query.getColumns();
    List<String> columnList = Lists.newArrayList();
    for (SelectItemExpression columnItem : columnItemList) {
      String columnName = StringUtils.substringBefore(columnItem.getExpression().toString(), "[detail");
      columnList.add(columnName);
    }
    List<Object> outList = Lists.newArrayList();
    List<List<Object>> resultList = outResults.getResults();   // 无判空？？？？？？？？？？？？？？？
    for (List<Object> rowList : resultList) {
      Object object = newInstance(clazz.getName());
      for (int j = 0; j < columnList.size(); j++) {
        setFieldValue(object, columnList.get(j), rowList.get(j));
      }
      outList.add(object);
    }
    return (T) outList;
  }
}
```

# Bug: Possible null pointer dereference of myClass in com.m5173.mobile.category.common.utils.JoSqlListUtils.newInstance(String) on exception path

```java
private static Object newInstance(String classFullName) {
  Class myClass = null;
  Object myInstance = null;
  try {
    myClass = Class.forName(classFullName);
  } catch (ClassNotFoundException e) {
    e.printStackTrace();
  }
  try {
    myInstance = myClass.newInstance();  // 可能空指针，判断一下
  } catch (InstantiationException e) {
    e.printStackTrace();
  } catch (IllegalAccessException e) {
    e.printStackTrace();
  }
  return myInstance;
}
```
