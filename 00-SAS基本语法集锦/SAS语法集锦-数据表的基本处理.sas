/****************  SAS管理  ****************/
* 建立逻辑库，分别用MySQL、ORACLE、ODBC、EXCEL方式连接 ;
LIBNAME lib_name MYSQL
    USER     = "root"
    PASSWORD = ""
    DATABASE = test 
    SERVER   = localhost 
    PORT     = 3306
    PRESERVE_TAB_NAMES=YES;
LIBNAME lib_name ORACLE
    USER     = "root"
    PASSWORD = ""
    PATH = test                *这是tnsnames.ora中配置的连接名字;
    SCHEMA = aaa
    PRESERVE_TAB_NAMES=YES;
LIBNAME lib_name ODBC
    DSN = "MySQL-localhost"
    UID = root
    PWD = ""
    PRESERVE_TAB_NAMES=YES;       
LIBNAME lib_name EXCEL
    "xxx.xls";                *这是具体文件的名字;
  
* 删除逻辑库;
LIBNAME libname CLEAR;





/****************  数据管理技巧  ****************/
* 创建/删除索引，创建索引后不能在对该表进行排序;
DATA aaa (INDEX = (x));
    INPUT x y z;
    CARDS;
    1 2 3
    4 5 6
    ;
RUN;
PROC DATASETS LIB = work;
  modify tablename;
  INDEX CREATE Z /NOMISS UNIQUE;                  * 定义单一索引; *NOMISS从索引中删除空值，UNIQUE规定变量值必须唯一;   
  INDEX CREATE xyz = (x y z) /NOMISS UNIQUE;      * 定义复合索引;
QUIT;

PROC DATASETS LIB = work;
  modify tablename;
  INDEX DELETE _ALL_;     * 删除所有索引;   
  INDEX DELETE xyz ;      * 删除指定索引;
QUIT;

* 连接外部数据库;
PROC SQL;
  CONNECT TO oracle(USER = xxx PASSWORD = xxx PATH = xxx  SCHEMA = xxx);
  CREATE TABLE table_name AS SELECT * FROM CONNECTION TO oracle (SELECT * FROM test1.db1);
  DISCONNECT FROM oracle;
QUIT;

/* 定义一张空的表，只定义表结构;
  该语句定义了3个字段：name，date，amount
  其中，LABEL表示字段的标签（类似于ORACLE表中的注释），FORMAT表示输出格式，INFORMAT表示输入格式，LENGTH表示字段格式和长度
  其中$4.表示column1为宽度4的字符串，yymmdd10表示长度为10的日期型，10.2表示数字，整数10位小数2位
  数据类型的定义：
  字符型 $CHARw. $HEXw. $w. 
  日期型 DATEw. DATETIMEw. DDMMYYw. JULIANw. MMDDYYw. TIMEw. 
  数字型 COMMAw.d HEXw. IBw.d PDw.d PERCENTw. w.d 
*/
DATA table_name;
    ATTRIB name   LABEL="NAME" LENGTH=$10
           date   LABEL="BIRTHDAY" FORMAT=yymmdd10. INFORMAT=mmddyy10.
           amount LABEL="MONEY" FORMAT=10.2;         
RUN;

* 通过SET处理数据;
DATA sasuser.cls;
    SET c9501;
    IF chinese>100 THEN chinese=100;       *修改数据集，把超过100分的语文成绩改为100分
    KEEP name avg;                         *用KEEP保留部分变量
    KEEP = name avg;                       
    DROP sex math chinese;                 *用DROP去掉部分变量
    RENAME name=chinesename;               *用RENAME重命名变量  
    RENAME = (Cat = Feline Dog = Canine);
    IF math>=90 and chinese>=100;          *只取数学成绩大于90且语文成绩大于100分的记录     
    WHERE math>=90 and chinese>=100;         
    WHERE = (math>=90 and chinese>=100);         
    FIRSTOBS = 5；                         *用FIRSTOBS控制导入内容从第2行开始
    OBS = 100；                            *用OBS控制只导入100行
RUN;

*同时建立2张表，保留不同变量;
DATA tablename1(KEEP = xxx xxx ) tablename2(KEEP = xxx xxx xxx) ;
  SET xxx (KEEP = xxx xxx xxx);
RUN;

* 根据条件拆分成2个新数据集;
DATA c9501m c9501f;
    SET c9501;
    SELECT(sex);
        WHEN('男') output c9501m;
        WHEN('女') output c9501f;
        OTHERWISE PUT SEX= '有错';
    END;
    DROP sex;
RUN;


/*数据集复杂合并
原始数据：
Max Flight      running 1930
Zip Fit Leather walking 2250
Zoom Airborne   running 4150
Light Step      walking 1130
Max Step Woven  walking 2230
Zip Sneak       c-train 1190
*/
DATA shoes;                                          --导入原始数据shoes
    INFILE 'c:\MyRawData\Shoesales.dat';
    INPUT Style $ 1-15 ExerciseType $ Sales;
PROC MEANS NOPRINT DATA = shoes;                     --产生新的数据集summarydata，只有一列GrandTotal，值为SUM(Sales)
    VAR Sales;
    OUTPUT OUT = summarydata SUM(Sales) = GrandTotal;
PROC PRINT DATA = summarydata;
TITLE 'Summary Data Set';
DATA shoesummary;                                    --产生新的数据集shoesummary
    IF _N_ = 1 THEN SET summarydata;                 --IF _N_ = 1的写法表示将summarydata中的唯一字段扩展到下面表的每一列
    SET shoes;                                       --导入shoes表
    Percent = Sales / GrandTotal * 100;              --增加Percent列
RUN;

* 数据有条件抽取
DATA walkers;
    INFILE 'c:\MyRawData\Walk.dat';
    INPUT Entry AgeGroup $ Time @@;
    PROC SORT DATA = walkers;
    BY Time;
DATA ordered;
    SET walkers;
    Place = _N_;               *新建一个字段Place值为_N_，_N_表示读取源文件循环的次数，1，2，3，……;
PROC SORT DATA = ordered;
    BY AgeGroup Time;
DATA winners;
    SET ordered;
    BY AgeGroup;
    IF FIRST.AgeGroup = 1;     *FIRST.后面跟一个变量，通常和BY关键字合用，这里的意思是只取每一个AgeGroup值第一次出现的记录，类似用法有LAST.;
RUN;
/*源数据：
54 youth 35.5 21 adult 21.6 6 adult 25.8 13 senior 29.0
38 senior 40.3 19 youth 39.6 3 adult 19.0 25 youth 47.3
11 adult 21.9 8 senior 54.3 41 adult 43.0 32 youth 38.6

ordered数据：
Entry Group Time Place
3  adult   19.0  1
21 adult   21.6  2
11 adult   21.9  3
6  adult   25.8  4
13 senior  29.0  5
54 youth   35.5  6
32 youth   38.6  7
19 youth   39.6  8
38 senior  40.3  9
41 adult   43.0  10
25 youth   47.3  11
8  senior  54.3  12

winners数据：
Entry Group Time Place
3   adult    19.0   1
13  senior   29.0   5
54  youth    35.5   6
*/


* IN的用法：可以把SET后面不同的数据集通过标示变量区分，但由于IN本身不是变量，所以要用别的临时变量赋值;
DATA one;
  INPUT x y $ @@;
  CARDS;
  1 A 2 B 3 C
  ;
DATA two;
  INPUT x z $ @@;
  CARDS;
  4 D 5 E
  ;
DATA IN1;
  SET ONE(IN=ina) TWO(IN=inb);
  in_one = ina;
  in_two = inb;
RUN;
* 或：;
DATA IN2;
  SET ONE(IN=ina) TWO(IN=inb);
  IF ina = 1 THEN flag = 1; ELSE flag = 0;
  in_two = inb;
RUN;

* NOBS用法：读取数据集的观测数量;
DATA nobs1;
  SET one NOBS = total_obs;
  total = total_obs;
  OUTPUT;
  STOP;
RUN;
* 或：下述IF条件不成立，所以实际是不会执行的，但SAS是先编译后执行，编译时已把one表的头文件信息传递给变量total_obs;
DATA nobs2;
  IF (1=2) THEN SET ONE NOBS = total_obs;
  total = total_obs;
  OUTPUT;
  STOP;
RUN;

* POINT用法：读取指定观测，注意POINT=后面只能跟变量，不能跟常数;
DATA point1;                   *获取某条数据；
  n = 3;
  SET one point = n;
  OUTPUT;
  STOP;
RUN;
DATA point2;                   *获取某几条数据；
  DO n = 1,3;
    SET one point = n;
    OUTPUT;
  END;
  STOP;
RUN;
DATA point3;                   *获取最后一条数据；
  SET one NOBS = last point = last;
  OUTPUT;
  STOP;
RUN;

* END用法：获取数据集是否到末尾一条观测;
DATA end1;
  SET one END = last_obs;
  flag = last_obs;
RUN; 

* 将数据分别拷贝至多个表;
DATA d1 d2;
  SET one;
  IF _N_ LE 2 THEN OUTPUT d1;
  ELSE OUTPUT d2;
RUN;

* 单个SET和多个SET的差异：
* 下述前2例，内存双指针同时读取a、b表并集中到新表，读到b表第2条记录后完成，跳出，所以ab、ba表均只有2条记录;
* 而第3例，内存只有一个指针，依次读取a、b表内容，所以共产生5个观测。
DATA a;
  INPUT x $ @@;
  CARDS;
  a1 a2 a3
  ;
DATA b;
  INPUT y $ @@;
  CARDS;
  b1 b2
  ;
DATA ab;
  SET a; SET b;
DATA ba;
  SET b; SET a;
DATA a_b;
  SET a b;
RUN;


* 多个数据集的横向合并（类似于SQL的表和表的外关联），KEY用法;
DATA a;                                   * 主表，3个学生的语文成绩;
  INPUT name $ chinese_score $ @@;
  CARDS;
  张三 82 李四 69 王五 91
  ;
DATA b;
  INPUT name $ math_score $ @@;           * 查询表，只有2个学生的数学成绩;
  CARDS;
  李四 93 张三 88 
  ;
RUN;
PROC DATASETS LIB = work;                 * 给查询表建索引，学生的姓名，作为KEY值;
  MODIFY b;
  INDEX CREATE name /NOMISS UNIQUE;
QUIT; 
DATA ab;
  SET a;
  SET b KEY = name;                       * KEY关键字表名根据b的name字段联动查询当前a查到的姓名;
  all_score = chinese_score+math_score;   * 新表生成字段：总分;
RUN;
* 上述查询有瑕疵，对于王五，b表没有数学成绩，系统自动赋值为上次查到的数学成绩，即李四的93分，改进算法如下，匹配成功纳入表abb，不成功的纳入表abbb：;
DATA abb abbb;
  SET a;
  SET b KEY = name;                       
  IF _IORC_ = 0 THEN DO;                    * _IORC_自动变量，匹配成功返回0，不成功
    all_score = chinese_score+math_score;   * 新表生成字段：总分;
    OUTPUT abb;
  END;
  ELSE DO;
    all_score = _ERROR_ ;
    iorc =  _IORC_ ;
    OUTPUT abbb;
  END;
RUN;

* 多个数据集的横向合并（类似于SQL的表和表的外关联），MERGE用法;
DATA aabb;            *MERGE没有BY的情况下，两张表粗暴一对一合并，相同的变量名，后者内容覆盖前者;
  MERGE a b;
DATA aaabbb;          *MERGE有BY的情况下，根据BY的变量值关联合并，但需要两张表提前排好序;
  MERGE a b;
  BY name;
RUN;
DATA mergea mergeb;
  MERGE a b( RENAME = (math_score = mathscore) IN = x );    * 为防止主表重名字段被辅查表字段覆盖，常需要将辅查表字段更名，同时判断辅查表是否能查到记录，查不到的话，另表存以示区别;
  BY name;
  IF x THEN OUTPUT mergeb;
  OUTPUT mergea;
RUN;

* 多个数据集的横向合并（类似于SQL的表和表的外关联），UPDATE用法。;
* UPDATE后面只能跟2个数据集，必须跟BY联用，必需提前排序或建索引，可用UPDATEMODE=MISSINGCHECK|NOMISSINGCHECK指定对于缺失值是否更新;
PROC SORT DATA=a; BY name ; RUN;
PROC SORT DATA=b; BY name ; RUN;
DATA test;
  UPDATE a b UPDATEMODE = NOMISSINGCHECK ;
  BY name;
RUN;

* 多个数据集的横向合并（类似于SQL的表和表的外关联），MODIFY用法。;
* UPDATE后面只能跟2个数据集，必须跟BY联用，必需提前排序或建索引，可用UPDATEMODE=MISSINGCHECK|NOMISSINGCHECK指定对于缺失值是否更新;
* 1)匹配访问：DATA后面的表和MODIFY后面第一张表名字应该一样;
DATA masterdata;
  MODIFY masterdata transactiondata;
  BY variable;
RUN;
* 2)索引访问：;
DATA masterdata;
  SET transactiondata;
  MODIFY masterdata KEY = variable</UNIQUE>;
RUN;
* 3)观测序号访问：;
DATA masterdata;
  SET transactiondata;
  MODIFY masterdata POINT = variable;
RUN;
* 4)顺序访问：???;
DATA masterdata;
  MODIFY masterdata < NOBS = variable END = variable>;
RUN;
* MODIFY实例1：;
DATA a1 (INDEX = (x));
  INPUT x y @@;
  CARDS;
  101 1 1 10 2 20 3 30
  ;
RUN;
DATA b1;
  INPUT x y @@;
  CARDS;
  1 100 2 200
  ;
RUN;
DATA b2;
  INPUT x y @@;
  CARDS;
  1 100 2 200 2 280
  ;
RUN;  
DATA b3;
  INPUT pnt y @@;
  CARDS;
  2 200 3 300 4 400
  ;
RUN;  
DATA a1;                  * 将a1表的y值改为b3表的;
  MODIFY a1 b3( RENAME = (pnt=x) )
  BY x;
  PUT _IORC_ = ;
RUN;
DATA a1;                  * 将a1表的y值有条件更改，这个功能也可由SET实现，但是效率比SET高;
  MODIFY a1；             * SET需要度每一条观测进入内存判断后再回写，而MODIFY采用动态查询，查询动作在编译后即产生，不会把所有记录都读入内存;
  IF x = 2 THEN y = 200;
RUN;

* MODIFY实例2：将每日交易汇入历史汇总表;
DATA mastertrans;
  INPUT userid transamt @@;
  CARDS;
  101 1000 102 1500 103 2000
  ;
RUN;
DATA daytrans;
  INPUT userid dayamt @@;
  CARDS;
  102 50 102 60 103 30 110 80
  ;
RUN;
DATA mastertrans;
  MODIFY mastertrans daytrans;
  BY userid;
  transamt = transamt + dayamt;
  IF _IORC_ = 0 THEN REPLACE;       * 匹配成功，替换原来的值;
  ELSE DO;                          * 匹配不成功，把transamt赋值为当天的交易值，并通过OUTPUT给mastertrans表新增一条记录;
    transamt = dayamt;
    _ERROR_ = 0;
    OUTPUT;
  END;
RUN;

* MODIFY/REMOVE/DELETE/效率对比;
DATA a;
  MODIFY a;
  IF month = "&data_month" THEN REMOVE;         * 效率最高;
RUN;
DATA a;
  SET a;
  IF month = "&data_month" THEN DELETE;         * 效率其次;
RUN;
PROC SQL;
  DELETE FROM a WHERE month = "&data_month";    * 效率最低;
QUIT;




* KEEP/DROP用法;
DATA a1;
  SET sashelp.class;
  KEEP name weight;
RUN;
DATA a2;
  SET sashelp.class (KEEP = name weight);   * 这两种写法结果是一样的，但后者效率高;
RUN;
DATA a3;
  SET sashelp.class (KEEP =_CHARACTER_);   * 保留所有字符变量;
RUN;
DATA a3;
  SET sashelp.class (KEEP =_NUMERIC_);   * 保留所有数字变量;
RUN;

* RETAIN用法：往往和FIRST.VARIABLE和LAST.VARIABLE连用，实现汇总、累加、纵向比较、创建flag、处理缺失变量等功能;
DATA retaina;
  INPUT id txn_cde$ cns txn_dte$;
  CARDS;
  10 101 10 20070101
  10 101 20 20080402
  10 201 30 20050203
  20 201 50 20040105
  20 301 60 20070806
  20 201 70 20050607
  30 301 80 20070501
  30 401 90 20070306
  ;
RUN;
PROC SORT DATA = retaina; BY id ;
RUN;
DATA retainb;                                    * 一个汇总的案例（类似SQL的GROUP BY用法）;
  SET retaina;
  BY id ;                                        * 根据id汇总;
  RETAIN min_dte sum_cns cnt cnt_condition;      * 保留并控制这几个变量在循环中按要求计算;
  IF first.id THEN DO;                           * 如果是BY汇总后的第一条观测，则初始化各项变量;
    min_dte = txn_dte;
    sum_cns = 0;
    cnt = 0;
    cnt_condition = 0;
  END;
  min_dte = MIN(min_dte,txn_dte);                * 对于每重循环读取变量值，min_dte都记最小的txn_dte;
  sum_cns + cns;                                 * 对于每重循环读取变量值，sum_cns累计cns;
  cnt + 1;                                       * cnt每次都在原基础上加1;
  cnt_condition + (txn_cde IN ('101','201'));    * cnt_condition仅在txn_cde IN ('101','201')时累加1;
  IF last.id;                                    * 该处条件满足的话，才执行RUN，否则不执行，所以BY分组后仅在读取到最后一条记录后才运行RUN把当前变量值写入retainb;
RUN;









/****************  实用的PROC过程步  ****************/
* APPEND追加数据;
PROC DATASETS 
  LIBRARY = WORK FORCE;
  APPEND OUT = b   DATA = sashelp.class;          * 将数据集sashelp.class加载到数据集B中;
RUN; 

PROC APPEND 
  BASE = b DATA = sashelp.class(WHERE = (sex='M'));   * 将数据集sashelp.class中性别为男的记录加载到数据集B中;
RUN;

* SORT排序数据;
PROC SORT 
  DATA = b NODUPKEY/NODUPRECS/FORCE OUT = a;     * 根据x字段对表b排序。NODUPKEY删除重复的主排序变量值，NODUPRECS删除重复观测值，FORCE强制实施多余排序;
  BY x DESCENDING;                               * DESCENDING降序排列;OUT把排序结果输出至a表，通常与NODUPKEY、NODUPRECS合用，避免错删原表数据;
RUN;

* TRANSPOSE转置数据;
PROC TRANSPOSE DATA = baseball OUT = flipped NAME=fields PREFIX=aa;  * OUT指定转置变量的名字，NAME指定后需新增字段名前缀,PREFIX指定转职后新增变量名的前缀，没有的话默认col1,col2……;
    BY Team Player;   * BY指定分组变量;
    ID Type;          * 变量值为转置后数据集的变量名，如果没有ID，转置后新增列集默认为aa1,aa2,……;
    VAR Entry;        * VAR为要转置的变量，如果没有VAR，则没有列在其他语句中的所有数值变量将被转置;
RUN;
* 例如源数据集：;
DATA scores;
  INPUT name $ year course $ score;
  CARDS;
Alice 2014 chinese 92
Alice 2014 math    78
Alice 2014 english 83
Alice 2015 chinese 86
Alice 2015 math    83
Jamse 2014 chinese 67
Jamse 2014 math    94
Jamse 2014 english 87
Jamse 2015 chinese 81
Jamse 2015 math    90
Jamse 2015 english 85
RUN;
PROC SORT 
  DATA = scores; 
  BY name year; 
RUN;
* 行转列转置后变为：;
PROC TRANSPOSE 
  DATA = scores OUT = scores1 NAME=fields Prefix=aa;  
  BY name year;  
  ID course;     
  VAR score;     
RUN;
/*
name  year  以前的变量名  aachinese aamath  aaenglish
Alice 2014  score         92        78      83
Alice 2015  score         86        83      .
Jamse 2014  score         67        94      87
Jamse 2015  score         81        90      85
*/ 
   
* 也可以列转行：;
PROC TRANSPOSE 
  DATA = scores1 OUT = scores2(RENAME = (aamath=course));  
  BY name year;  
  VAR aachinese aamath aaenglish;     
RUN;
                 
* 在商业实践中应避免使用TRANSPOSE过程，特别是在大数据集下，非常消耗时间，而TRANSPOSE本质上是在程序后台运行DATA步：;
* 行转列：;
DATA scores3 ;     * DO循环包含SET语句，同时不使用OUTPUT，程序在DO循环中把循环粗疏对应读入的观测条数赋值给不同变量，最后通过RUN语句输出;
  DO i=1 TO 3;
    SET scores(KEEP = name year score);
    ARRAY tr[1:3] chinese math english;;
    tr(i) = score;
  END;
  KEEP  name year chinese math english;;
RUN;

DATA scores5 ;     
  SET scores;
  BY name year; 
  ARRAY tr[1:3] chinese math english;
  RETAIN chinese math english;
  IF FIRST.name THEN 
    DO i=1 TO 3;
      tr(i) = score;
  END;
  SELECT (course);
    WHEN ('chinese') chinese = score;
    WHEN ('math')    math = score;
    WHEN ('english') english = score;
    OTHERWISE;
  END;
  IF LAST.year;
  KEEP  name year chinese math english;
RUN;

* 列转行：;
DATA scores4 ;     * DO循环独立于SET语句，同时使用OUTPUT语句，保证程序每读入一条观测，动过DO循环和OUTPUT语句输出多条观测;
  SET scores1;    
  ARRAY tr[1:3] aachinese aamath aaendlish;
  DO i=1 TO 3;
    measurement = tr(i);
    OUTPUT;
  END;
RUN;

* CONTENTS输出逻辑库成员的描述信息，即头文件;
PROC CONTENTS
  DATA =                  * 指定数据集;
  DETAILS|NODETAILS       * 指定是否包含观测数、变量数、数据集标签;
  DIRECTORY               * 输出逻辑库中所有成员列表;
  FMTLEN                  * 输出变量的输入格式和输出格式长度;
  MEMTYPE = ACCESS|ALL|CATALOG|DATA|PROGRAM|VIEW   * 指定输出逻辑库的一个或多个成员的类型; 
  NODS                    * 限制输出单个成员信息，仅输出逻辑库的目录; 
  NOPRINT                 * 指定不输出CONTENTS内容结果，此时必须规定OUT=; 
  ORDER = IGNORECASE      * 指定变量列表按照字母顺序输出; 
  OUT =                   * 指定输出的SAS数据集名字; 
  SHORT                   * 只输出SAS数据集变量列表; 
  VARNUM                  * 指定变量列表按照它们在SAS数据集中的逻辑位置输出;
RUN;
* 例子：;
PROC CONTENTS             * 输出sashelp逻辑库下所有成员信息;
  DATA = sashelp._ALL_ ;
RUN;
PROC CONTENTS             * 输出sashelp逻辑库下SAS数据集和CATALOG成员信息;
  DATA = sashelp._ALL_ MEMTYPE = (DATA CATALOG);
RUN;
PROC CONTENTS             * 输出sashelp逻辑库下class表的信息到class_inf表;
  DATA = sashelp.class OUT =class_inf;
RUN;
* DATASET对逻辑库中所有成员增删改查等操作;
PROC DATASETS 
  LIBRARY=NETSDWA;      *给表变量改名字;
  MODIFY TMP_2014061616144215_4;
  RENAME 主客户号=MASTER_PARTY_ID;
  RENAME 从客户号=PARTY_ID;
  RENAME 从客户号对应的专业公司客户号=CLIENT_NO;
RUN;
PROC DATASETS                    * 逻辑库间数据集拷贝与移动。;                                                   
  COPY IN = work OUT =ss06;      * COPY:将所有数据集拷贝到另一逻辑库中   MOVE: 将所有数据集移动到另一逻辑库中;  
  EXCLUDE Invoice;               * SELECT：选择要copy或move操作的数据集  EXCLUDE：排除进行copy或move操作的数据集;
RUN;

PROC DATASETS 
  LIBRARY = work;    * SAVE：保留哪些数据集  DELETE：删除哪些数据集  KILL：删除全部数据集;
  DELETE Invoice;
RUN;
PROC DATASETS 
  LIBRARY = work  KILL;
RUN;
PROC DATASETS 
  LIBRARY = work FORCE;    * 使用append将数据集A加载到数据集B中;
  APPEND OUT = b   DATA = a;
RUN;
PROC DATASETS 
  LIBRARY = work;   * 用change对数据集更名，下面是将数据集one更名为two;
  CHANGE one =two;
RUN;
PROC DATASETS 
  LIBRARY = work;                        * modify更改数据集属性，以及变量属性;
  MODIFY Invoice (LABEL = ‘NEW_MEMBER_LABEL’);
  RENAME custname = NEW_VARIABLE_NAME;
  LABEL  custname = LABEL_FOR_RENAMED_VARIABLE;
  FORMAT custname COMMA11.2;  
RUN;
PROC DATASETS 
  LIB =work;     * exchange数据集互换名字，这个程序蛮有意思的;
  EXCHANGE invoice = One;
RUN; 

