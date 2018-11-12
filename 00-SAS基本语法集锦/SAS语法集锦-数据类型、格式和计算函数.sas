/****************  SAS基本数据类型  ****************/
数值型（定义时通常用x.x表示，x为具体数字，表示数值长度格式）：12, -7.5, 2.5E-10
字符型（定义时通常用$表示）：'Beijing', "Li Ming", "李明"
日期型（DATE）：'13JUL1998'd
时间型（TIME）：'14:20't
日期时间型（DATETIME）：'13JUL1998:14:20:32'dt


/****************  数值型常用数据格式  ****************/
x=1257000
put x best6.; 1.26E6
put x best3.; 1E6
put @10 sales comma10.2;  *带逗号格式数据，保留2位小数;
d10.4  *把相同数量级的数据的小数精度控制一致，不同数量级的不一样;
dollar10.2  *小数点2位，前面带美元符号;
e10.  *科学计数法，10表示输出数据宽度;
fract8.  *把数字改成比例形式，8表示输出字符宽度;
percent10.2 *把数字改成百分比形式，10表示总体宽度，2表示小数点后位数;



/****************  日期型DATE常用数据格式  ****************/
* 定义          展示形式              说明;             
  DATE9.        16MAR2003
  DAY2.;        14                    *返回日期的天
  DDMMYY10.;    24/12/2005
  DDMMYYP10.;   16.03.2005
  DDMMYYN8.;    16032005
  DOWNAME.;     Sunday               *返回是星期几;
  JULDAY3.;     75                   *返回日期在一年中的第几天1997-3-16
  JULIAN7.;     2005358              *返回日期在一年中的第几天2005-12-24
  MINGUOw.                           *返回民国日期格式
  MMDDYY10.;    10/25/2005
  MMDDYYP10.;   10.22.2005
  MMDDYYN8.;    10222005
  MMYY5.;       10M05
  MMYY7.;       10M2005
  MMYY10.;      10M2005
  QTR.;         1                    *返回日期所属的季度数
  QTRR.;        III                  *返回日期所属的季度数的罗马数值
  WEEKDATE3.;   Tue
  WEEKDATE9.;   Tuesday
  WEEKDATE15.;  Tue, Jun 14, 05
  WEEKDATE17.;  Tue, Jun 14, 2005
  WEEKDAY.;     4                    *返回日期对应当周的第几天（从周日算起）
  YYMMDD10.;    2005-04-03
  YYMMDDP10.;   2005.10.22
  YYMMDDN8.;    20051022
  YYQ5.;        05Q2
  YYQ6.;        2005Q2
  
/****************  日期时间型DATETIME常用数据格式  ****************/
* 定义          展示形式              说明;             
  DATEAMPM.     20APR03:11:01:34 AM
  DATEAMPM13.   20APR03:11 AM
  DATEAMPM22.2  20APR03:11:01:34.00 AM
  DATETIME.;    10NOV05:03:49:19
  DATETIME18.1; 10NOV05:03:49:19.0
  DATETIME19.;  10NOV2005:03:49:19
  DATETIME20.1; 10NOV2005:03:49:19.0
  DATETIME21.2; 10NOV2005:03:49:19.00
  DTMONYY.;     OCT06
  DTMONYY7.;    OCT2006
  DTWKDATX.;    Monday, 16 October 2006
  DTWKDATX3.;   Mon
  DTWKDATX8.;   Mon
  DTWKDATX25.;  Monday, 16 Oct 2006
  DTYEAR.;      2006
  DTYEAR2.;     06
  YEAR4.;       2006

/****************  时间型TIME常用数据格式  ****************/
* 定义          展示形式              说明;             
  HHMM.;        13:00
  HHMM8.2;      12:59.93
  HOUR4.1;      11.5
  TIME.;        16:24:43

/**********SAS数据类型转换**********/
* 数字—>字符;
DATA newlist; 
    SET newdata.maillist; 
    zipcode = PUT(zip,z5.);   *z5.表示转换为长度5的子符，左边补0，如果是5.则左边补空格;
RUN;

* 字符—>数字;
DATA newlist; 
    SET newdata.maillist; 
    zipcode = INPUT(zip,8.); 
RUN;




/**********SAS运算逻辑**********/
算术运算：+ - * / **(幂次方) ^（幂次方）
比较运算：=(EQ) ^=(NE或~=) >(GT) <(LT) >=(GE) <=(LE) IN
逻辑运算：&(AND) |(OR或!) ?(NOT)    
          ……IS NOT MISSING  
          BETWEEN ……AND…… 
          CONTAINS ……
          IN ( list )

/**********SAS数值型运算函数**********/
* 算式                          说明;
  SUM(x1,x2,x3)                 *求x1,x2,x3变量之和;
  SUM(OF x1-x3)                 *求x1,x2,x3变量之和;
  ABS(x)                        *绝对值;
  MAX(x1,x2,,,xn)               *最大值;
  MIN(x1,x2,,,xn)               *最小值;
  MOD(x,y)                      *求模，X除以Y的余数;
  SQRT(x)                       *平方根;
  ROUND(x,eps)                  *求x按照esp指定的精度四舍五入后的结果，例如ROUND (5654.5654, 0.01)=5654.57, ROUND(5654.5654,10)=5650;
  CEIL(x)                       *求大于等于x的最小整数;
  FLOOR(x)                      *求小于等于x的最大整数;
  INT(x)                        *求x的整数部分;
  FUZZ(x)                       *当x与其四舍五入整数值相差小于1E-12时取四舍五入;
  LOG(x)                        *自然对数;
  LOG10(x)                      *常用对数;
  EXP(x)                        *指数幂函数，e的x次方;
  SIN(x), COS(x), TAN(x)        *三角函数;
  ARSIN(y),ARCOS(y),ATAN(y)     *反三角函数;
  SINH(x), COSH(x), TANH(x)     *双曲正弦、余弦、正切;
  ERF(x)                        *误差函数;
  GAMMA(x)                      *完全F函数;

/**********SAS字符串运算函数**********/
* 算式                              说明;
TRIM(s)                             *剔除空格;
UPCASE(s),LOWCASE(s)                *大小写转换;
INDEX(s,s1), INDEXC, INDEXW,        *返回字符或字符串的起始位置;
RANK(s),BYTE(n)                     *字符和ASCII值互转;
REPEAT(s,n)                         *s重复n次;
SUBSTR(s,p,n)                       *子串;
TRANWRD(s,s1,s2) TRANSLATE,         *替换;
COLLATE, 
COMPRESS(string,chars,'modifier'),  *从string中移除chars字符，如果只有string参数，则移除空格；modifier指定修饰符不区分大小写;
LEFT,RIGHT,                         *左对齐变量值，右对齐变量值;
LENGTH,                             *返回字符长度;
SCAN(string,i,'char'),              *表示从字串string中以char为分隔符提取第i个字串;
REVERSE,    VERIFY, COMPBL, DEQUOTE,  QUOTE, SOUNDEX, TRIMN, 

/**********SAS日期时间运算函数**********/
* 算式                              说明;
MDY(m,d,yr)                         *生成yr年m月d日的SAS日期值;
YEAR(date) MONTH(date) DAY(date)    *由date得到年份、月份、日;
HOUR, MINUTE, SECOND,
WEEKDAY(date)                       *由SAS日期值date得到星期几;
QTR(date)                           *由SAS日期值date得到季度值;
HMS(h,m,s)                          *由小时h、分m、秒s生成SAS时间值;
DHMS(d,h,m,s)                       *由SAS日期值d、小时h、分m、秒s生成SAS日期时间值;
DATEPART(dt), TIMEPART(dt)          *分别求SAS日期时间值的日期部分、时间部分;
INTNX(interval,from,n)              *计算日期from后面的第n个关于interval分界点的SAS日期。所谓interval的分界点是指interval的第一天，interval可以取'YEAR','QTR','MONTH','WEEK','DAY'等;
INTCK(interval,from,to)             *计算从日期from（不含）到日期to（含）中间经过的关于interval的分界点的个数，例如INTCK('YEAR','31Dec1996'd,'1Jan1998'd)=2;
DATE(), TODAY(), DATETIME,DATEJUL, JULDATE, TIME, 
YRDIF(stardate,enddate,'actual')    *返回两个日期之间的真实间隔年数;
DATDIF(stardate,enddate,'actual')   *返回两个日期之间的真实间隔天数（注意：计算两个日期之间的天数datdif和intck这两个函数的效果是一样的，就像date和today的效果相同一样）;

/**********SAS统计分布函数**********/
分布函数值=CDF('分布类型',x<,参数表>))
密度值=PDF('分布类型',x<,参数表>))
概率值=PMF('分布类型',x<,参数表>))
对数密度值=LOGPDF('分布类型',x<,参数表>))
对数概率值LOGPMF('分布类型',x<,参数表>))
--分布类型可取值为：BERNOULLI, BETA, BINOMIAL,CAUCHY, CHISQUARED, EXPONENTIAL,F, GAMMA, GEOMETRIC, HYPERGEOMETRIC,LAPLACE, LOGISTIC, LOGNORMAL, NEGBINOMIAL,NORMAL或GAUSSIAN, PARETO, POISSON,T, UNIFORM, WALD或IGAUSS, WEIBULL
--分位数函数：概率分布函数的反函数，其自变量在0-1之间
PROBIT(p) --标准正态分布左侧p分位数，结果在-5到5之间
TINV(p, df <,nc>) --自由度为df的t分布的左侧p分位数，可选参数nc为非中心参数
CINV(p,df <,nc>) --自由度为df的卡方分布的左侧p分位数，可选参数nc为非中心参数
FINV(p,ndf,ddf <,nc>) --F(ndf,ddf)分布的左侧p分位数，可选参数nc为非中心参数
GAMINV(p,a) --参数为a的伽马分布的左侧p分位数
BETAINV(p,a,b) --参数为(a,b)的贝塔分布的左侧p分位数
--随机数函数
UNIFORM(seed) --均匀分布随机数：seed必须是常数，取0或5位、6位、7位的奇数
RANUNI(seed)  --均匀分布随机数：seed为小于2的31次方减1的任意常数
NORMAL(seed)  --正态分布随机数：seed为0或5位、6位、7位的奇数
RANNOR(seed)  --正态分布随机数：seed为任意常数
RANEXP(seed)  --指数分布随机数：seed为任意数值，产生参数为1的指数分布的随机数，期望为1/lambda的指数分布可以用RANEXP(seed)/lambda得到
--样本统计函数
MEAN,MAX,MIN，SUM
N --非缺失数据的个数
NMISS --缺失数值的个数
VAR --方差
STD --标准差
STDERR --均值估计的标准误差，用STD/SQRT(N)计算
CV --变异系数
RANGE --极差
CSS --离差平方和
USS --平方和
SKEWNESS --偏度
KURTOSIS --峰度

--正则表达式匹配
DATA _NULL_;
   position=PRXMATCH('/[^1234567890]/', '135239085-');
   put position=;
RUN;

















