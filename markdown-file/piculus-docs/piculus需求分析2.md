##### 修复实名验证没成功的客户
###### 配置方案

|系统组别|修复代号|最大重试次数|重试间隔|方案状态|方案等级|描述|执行方式|
|---|---|---|---|---|---|---|
|PBAP|realNameAuthFixServiceImpl|5|`0 0/10 * * * ?`|正常|非常重要|TEST|自动|

###### 配置方案解释
> 服务端发送收集命令后`系统组别`的生产系统，首页》流程控制》发起收集广播
> 生产系统上报问题数据到服务端，可以在 首页》修复查询》检查异常查询
> 服务端根据配置方案确定方案状态，如果失效则不执行修复方案
> 服务端根据配置方案确定执行方式，如果手动则不执行修复方案，首页》流程控制》异常处理 中查询手动点击执行
> 服务端根据配置方案确定执行方式，如果自动则会根据重试间隔没10分钟（0 0/10 * * * ?）执行修复方案
> 服务端根据配置方案如果执行成功则不再重试，执行失败则根据重试间隔再次执行
> 服务端根据配置方案最大重试次数，当重试5次还是失败则不再重试

###### 修复前：
状态 0 初始;1 交易处理中;8 成功;9 失败;
SQL：SELECT * FROM TPBAP_TRD_CUSTOMER WHERE (STATUS = 0 OR STATUS = 9 OR STATUS = 1)

TRD_ID|TRD_NUM|TRD_CODE|CUS_CODE|REAL_NAME|ID_NUM|ID_TYPE|CUS_MOBILE|REMARK|STATUS|CHL_TRD_NUM|TYPE|CARD_NUM|BANK_MOBILE|BANK_CODE|PROV_CODE|CITY_CODE|PRE_TIME|END_TIME|
-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
21|OP170717102514100002|OP|100020170717101889|陈羽|37078119920215881X|1|15200000002||0||1||||||||

###### 修复成功后：
SQL：SELECT * FROM TPBAP_TRD_CUSTOMER WHERE `TRD_NUM` = ?

|TRD_ID|`TRD_NUM`|TRD_CODE|`CUS_CODE`|REAL_NAME|ID_NUM|ID_TYPE|CUS_MOBILE|REMARK|STATUS|CHL_TRD_NUM|TYPE|CARD_NUM|BANK_MOBILE|BANK_CODE|PROV_CODE|CITY_CODE|PRE_TIME|END_TIME|
|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
|16|AC170712173752100019|AC|100020160723100137|马川|342401199105243698|2|12345678998||8||2|||||||2017-08-0922:38:54|

SQL：SELECT * FROM TPBAP_CUS_CUSTOMER_AUTH WHERE `CUS_CODE` = ?

|`CUS_CODE`|TP_STATUS|EMAIL_STATUS|MOBILE_STATUS|BANKCARD_STATUS|ACTIVATE_STATUS|PERFECT_PERCENT|TP_TIME|
|-|-|-|-|-|-|-|-|
|100020170726102026|1|0|1|1|1|50|2017-08-1814:35:50|


##### 修复放款
###### 配置方案

|系统组别|修复代号|最大重试次数|重试间隔|方案状态|方案等级|描述|执行方式|
|---|---|---|---|---|---|---|
|PBAP|lendingFixServiceImpl|5|`0 0/10 * * * ?`|正常|非常重要|TEST|自动|

###### 配置方案解释
> 服务端发送收集命令后`系统组别`的生产系统，首页》流程控制》发起收集广播
> 生产系统上报问题数据到服务端，可以在 首页》修复查询》检查异常查询
> 服务端根据配置方案确定方案状态，如果失效则不执行修复方案
> 服务端根据配置方案确定执行方式，如果手动则不执行修复方案，首页》流程控制》异常处理 中查询手动点击执行
> 服务端根据配置方案确定执行方式，如果自动则会根据重试间隔没10分钟（0 0/10 * * * ?）执行修复方案
> 服务端根据配置方案如果执行成功则不再重试，执行失败则根据重试间隔再次执行
> 服务端根据配置方案最大重试次数，当重试5次还是失败则不再重试

###### 修复前：
状态 0 未放款、1 放款处理中、2 投资人已放款 3备付金转账中 8 放款成功
SQL：SELECT * FROM TPBAP_TRD_LENDING WHERE STATUS = 1

|TRD_ID|TRD_NUM|CUS_CODE|ACC_CODE|PRD_CODE|TRD_AMOUNT|DED_AMOUNT|TRD_DATE|PRE_TIME|END_TIME|STATUS|SHD_STATUS|WD_STATUS|WD_TRD_NUM|
|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
|26|LN160729163830100005|100020160704100008|8812016070410008|PRD16072916354711195|950|50|2016-07-29|2016-07-2916:38:34|2016-07-2919:59:56|1|0|0||

###### 修复成功后：
SQL：SELECT * FROM TPBAP_TRD_LENDING WHERE `TRD_NUM` = ?

|TRD_ID|`TRD_NUM`|CUS_CODE|ACC_CODE|PRD_CODE|TRD_AMOUNT|DED_AMOUNT|TRD_DATE|PRE_TIME|END_TIME|STATUS|SHD_STATUS|WD_STATUS|WD_TRD_NUM|
|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
|28|LN160729184533100007|100020160704100008|8812016070410008|PRD16072916445311197|1450|50|2016-07-29|2016-07-2918:45:33|2017-08-1815:16:04|0|0|0||

SQL：SELECT * FROM TPBAP_TRD_LENDING_DET WHERE `LN_TRD_NUM` = ?

|TRD_ID|TRD_NUM|LN_TRD_NUM|TRD_AMOUNT|TRD_FEE|TRD_DATE|STATUS|PRE_TIME|END_TIME|CHL_TRD_NUM|FAILED_MSG|ACC_TRD_STATUS|ACC_TRD_NUM|ACC_TRD_TIME|IN_TRD_NUM|CUS_CODE|DED_AMOUNT|UN_FREEZE_ID|
|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
|14|LD160729185000100026|LN160729184533100007|1450|||0|2016-07-2919:02:17||||0|||IV160729171958100534|100020160725100191|0|100026|
|15|LD160729185000100027|LN160729184533100007|50|||9|2016-07-2919:02:17|2016-07-2919:02:46|GW160729190240102893|%E8%AF%B7%E6%B1%82%E5%8F%82%E6%95%B0%E9%9D%9E%E6%B3%95|0|||IV160729184526100541|100020160726100202|50|100027|


