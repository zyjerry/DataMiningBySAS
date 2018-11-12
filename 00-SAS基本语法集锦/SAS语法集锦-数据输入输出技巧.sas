/****************  数据导入技巧  ****************/
* INFILE用法：;
FILENAME files 'd:\utf.txt';
DATA unicode;
  INFILE files ENCODING = 'UTF-8';            * 从外部文件导入数据;
  INPUT name $ chinese_score;
RUN;

DATA num;
  INFILE DATALINES DSD;                       * 从下述文本导入数据，DSD设置默认分隔符为逗号，如果相邻两个逗号没有数据则默认为空;
  INPUT x y z;
  DATALINES;
  ,2,3
  4,5,6
  7,,9
  ;
RUN;

DATA num;
  INFILE DATALINES DSD DLM=' ';                * 从下述文本导入数据，DLM默认分隔符为空格;
  INPUT x y z;
  DATALINES;
2 3
4 5 6
7  9
  ;
RUN;

*新建一张表，数据来自于文本文件，字段之间以空格分开，其中字段名称后面的$表示该字段是字符型，5.3表示数字精度
DATA uspresidents;
    INFILE ’c:\MyRawData\President.dat’;
    INPUT President $ Party  Number 5.3 BirthDate MMDDYY10.;
RUN;

*新建一张表，数据来自于文本文件，字段之间固定列宽;
DATA uspresidents;
    INFILE ’c:\MyRawData\President.dat’;
    INPUT Name $ 1-10 Age 11-13 Height 14-18;
RUN;

*新建一张表，数据来自于文本文件，指定某字段到那一列为止
/*
--例如源文件内容为：
--Yellowstone           ID/MT/WY 1872       4,065,493
--Everglades            FL 1934             1,398,800
--Yosemite              CA 1864               760,917
--Great Smoky Mountains NC/TN 1926            520,269
--Wolf Trap Farm        VA 1966                   130
--其中@40表示读取year字段一直到第40列为止
*/
DATA nationalparks;
    INFILE ’c:\MyRawData\Park.dat’;
    INPUT ParkName $ 1-22 State $ Year @40 Acreage COMMA9.;
RUN;


*新建一张表，数据来自于文本文件
DATA impw;
	  INFILE ’c:\MyRawData\Park.dat’
		    DELIMITER=','  *字段以,分隔
	      LRECL=32767    *制定最大记录长度（SAS默认是256）
		    FIRSTOBS=2     *导入内容从第2行开始
		    OBS=100        *只导入100行
	  ;
	  LENGTH           *指定导入SAS数据集的字段长度
	  	party_no $ 12
	  	alias_party_no $ 12
	  	name $ 64
	  	sex $ 3
	  	certification_no $ 32
	  	type $ 4
	  	birthday 8
	  	certification_type $ 18
	  	addrss $ 60
	  	email $ 56
	  	content $ 24
    ;
	  INFORMAT        *指定字段输入格式
	  	birthday DATETIME18.
    ;
	  FORMAT          *指定字段显示格式
	  	birthday DATETIME18.
    ;
	  INPUT           *指定字段名
	  	party_no $
	  	alias_party_no $
	  	name $
	  	sex $
	  	certification_no $
	  	type $
	  	birthday : ANYDTDTM22.
	  	certification_type $
	  	addrss $
	  	email $
	  	content $
    ;
	  LABEL           *指定字段注释
	  	party_no = "party_no"
	  	alias_party_no = "alias_party_no"
	  	name = "name"
	  	sex = "sex"
	  	certification_no = "certification_no"
	  	type = "type"
	  	birthday = "birthday"
	  	certification_type = "certification_type"
	  	addrss = "addrss"
	  	email = "email"
	  	content = "content"
    ;
RUN;

*新建一张表，数据来自于文本文件，文件中多行变成一行
DATA highlow;
    INFILE ’c:\MyRawData\Temperature.dat’;
    INPUT City $ State $
        / NormalHigh NormalLow
        #3 RecordHigh RecordLow;
RUN;
/* 例如源文件内容为：
--Nome AK
--55 44
--88 29
--Miami FL
--90 75
--97 65
--Raleigh NC
--88 68
--105 50
--上述语句把文件内容变为：
--Nome    AK 55 44 88  29
--Miami   FL 90 75 97  65
--Raleigh NC 88 68 105 50
--其中/可以换为#2，#3也可换为/
*/

*新建一张表，数据来自于文本文件，文件中一行变成多行
DATA rainfall;
    INFILE ’c:\MyRawData\Precipitation.dat’;
    INPUT City $ State $ NormalRain MeanDaysRain @@;
RUN;
/*
--例如源文件内容为：
--Nome AK 2.5 15 Miami FL 6.75
--18 Raleigh NC . 12
--上述语句把文件内容变为：
--Nome    AK 2.5  15 
--Miami   FL 6.75 18 
--Raleigh NC . 12
*/

DATA theaters;
    INFILE 'c:\MyRawData\Movies.dat';
    INPUT Month $ Location $ Tickets @;
    OUTPUT;
    INPUT Location $ Tickets @;
    OUTPUT;
    INPUT Location $ Tickets;
    OUTPUT;
RUN;
/*例如源文件内容为：
Jan Varsity 56723 Downtown 69831 Super-6 70025
Feb Varsity 62137 Downtown 43901 Super-6 81534
Mar Varsity 49982 Downtown 55783 Super-6 69800
新数据集为：
Month Location Tickets
Jan Varsity 56723
Jan Downtown 69831
Jan Super-6 70025
Feb Varsity 62137
Feb Downtown 43901
Feb Super-6 81534
Mar Varsity 49982
Mar Downtown 55783
Mar Super-6 69800
*/

*数据来自于文本文件，有条件地选取内容
DATA freeways;
    INFILE ’c:\MyRawData\Traffic.dat’;
    INPUT Type $ @;
    IF Type = ’surface’ THEN DELETE;
    INPUT Name $ 9-38 AMTraffic PMTraffic;
RUN;
/*
例如源文件内容为：
freeway 408 3684 3459
surface Martin Luther King Jr. Blvd. 1590 1234
surface Broadway 1259 1290
surface Rodeo Dr. 1890 2067
freeway 608 4583 3860
freeway 808 2386 2518
surface Lake Shore Dr. 1590 1234
surface Pennsylvania Ave. 1259 1290
上述语句把文件内容变为：
freeway 408 3684 3459
freeway 608 4583 3860
freeway 808 2386 2518
*/

*新建一张表，数据来自于文本文件，有格式地选取内容
DATA icecream;
    INFILE ’c:\MyRawData\Sales.dat’ FIRSTOBS=3 OBS=5 MISSOVER TRUNCOVER DLM = ’,’ DLM = ’09’X DSD;
    INPUT Flavor $ 1-9 Location BoxesSold;
RUN;
/*
  FIRSTOBS=3 ：从源文件第3行开始读取数据；
  OBS=5      ：从源文件读取数据到第5行为止；
  MISSOVER TRUNCOVER：若源文件当前行没有数据而INPUT还有指定字段时，默认赋为NULL；
  DLM = ’,’ DLM = ’09’X  ：字段之间以某个特定符号为界，适用于csv等固定格式文件，’09’X 表示以ASCII码为09的符号分隔；
  DSD ：分隔符敏感，比如CSV文件中,,表示中间那个字段为NULL，而不是把,,算为,。
*/

*新建一张表，数据来自于文本文件，另增加部分字段，由其他字段或条件运算而来
DATA homegarden;
    INFILE 'c:\MyRawData\Garden.dat';
    INPUT Name $ 1-7 Tomato Zucchini Peas Grapes;
    Zone = 14;
    Type = 'home';
    Zucchini = Zucchini * 10;
    Total = Tomato + Zucchini + Peas + Grapes;
    PerTom = (Tomato / Total) * 100;
    IF Year < 1975 THEN Status = 'classic';
    IF Model = 'Corvette' OR Model = 'Camaro' THEN Make = 'Chevy';
    IF Model = 'Miata' THEN DO;
        Make = 'Mazda';
        Seats = 2;
    END;
    ELSE IF  Model = 'Cherry' THEN Make = 'Chevy';
    ELSE Make = 'Mazda';
RUN;
    
*新建一张表，数据来自于文本文件，根据条件选取部分数据   
DATA comedy;
    INFILE 'c:\MyRawData\Shakespeare.dat';
    INPUT Title $ 1-26 Year Type $;
    IF Type = 'comedy';
RUN;

DATA comedy;
    INFILE 'c:\MyRawData\Shakespeare.dat';
    INPUT Title $ 1-26 Year Type $;
    IF Type = 'tragedy' OR Type = 'romance' OR Type = 'history' THEN DELETE;
RUN;

DATA morning afternoon;
    INFILE 'c:\MyRawData\Zoo.dat';
    INPUT Animal $ 1-9 Class $ 11-18 Enclosure $ FeedTime $;
    IF FeedTime = 'am'        THEN OUTPUT morning;
    ELSE IF FeedTime = 'pm'   THEN OUTPUT afternoon;
    ELSE IF FeedTime = 'both' THEN OUTPUT;                --两个数据集都放
PROC PRINT DATA = morning;

RUN;


* PROC IMPORT导入数据;
*从文件中导入数据;
PROC IMPORT 
    DATAFILE = ’filename’          *源文件名;
    OUT = data-set                 *SAS数据集名;
    DBMS = CSV/TAB/DLM/EXCEL3/EXCEL5/EXCEL4/WK4/WK3/WK1/DBF REPLACE;    *BMS指定源文件类型，若是csv文件默认为,分隔，若是txt文件默认为tab分隔。REPLACE表示若数据集dataset已存在，是否替换;
    GETNAMES = YES;                 *默认第一行为字段名，若不想这样，则指定GETNAMES = NO;
    DELIMITER = ’delimiter-character’; *当DBMS=DLM时，在这里指定特殊的分隔符；
    SHEET = name-of-sheet;             *若文件类型是EXCEL，则在此指定要导入数据的sheet;
RUN;    
*从MS Access数据库中导入数据;
PROC IMPORT DATABASE = ’database-path’ DATATABLE = ’table-name’ OUT = data-set DBMS = identifier REPLACE;


* DATALINES;/CARDS用法：表示从下面读取数据，没有数据即空表
--新建表，包含column1，column2，column3，……column10 等10个字段
DATA table_name;
    INPUT column1-column10 ;
    DATALINES;/CARDS;
RUN;
*新建表，包含column1，column2，column3等3个字段，每个字段类型不同
DATA table_name;
    INPUT column1 $CHAR4. column2 DATE. column3 ;
    DATALINES;/CARDS;
    aaa 2011-09-01 bbb
    ccc 2011-09-02 ddd
    ;
RUN;





/****************  数据输出技巧  ****************/
* PUT用法：;
DATA p;
  INPUT x $ y z @@;
  CARDS;
  a 10 20 b 30 40 c 50 60
  ;
RUN;
DATA _NULL_;
  SET p;
  PUT x $ @;        * @表示不换行，下一个PUT继续在本行打印;
  PUT y   @;
  PUT z ;           * 打印到z后，就换行;
RUN;
/* 结果：
a 10 20
b 30 40
c 50 60
*/
DATA _NULL_;
  SET p;
  PUT x $ @;        
  PUT y   @;
  PUT z   @;       
RUN;
/* 结果：
a 10 20 b 30 40 c 50 60
*/
DATA _NULL_;
  SET p;
  PUT @10 x $ @;        * 在打印x之前空10个字符位置;
  PUT @15 y   @;
  PUT @20 z   ;       
RUN;
/* 结果：
         a    10   20
         b    30   40
         c    50   60
*/
DATA _NULL_;
  SET p;
  PUT x $ 10-14 @;        * 将每个变量固定在某些列的范围内;
  PUT y 15-19  @;
  PUT z 20-24  ;       
RUN;
/* 结果：
         a       10   20
         b       30   40
         c       50   60
*/
DATA _NULL_;
  SET p;
  PUT x $ 4-8 @;        
  PUT y 10-16 .3 @;      * 指定数字格式未小数点3个;
  PUT z 20-24 .2 ;       
RUN;
/* 结果：
   a      10.000   20.00
   b      30.000   40.00
   c      50.000   60.00
*/
DATA _NULL_;
  SET p;
  PUT x $ : @;             * 用冒号去掉输出值之间多余的空格;
  PUT y : 4.3 @;      
  PUT z: 7.2 ;     
  PUT 3*'here is char ';   输出固定的字符串3遍;
RUN;
/* 结果：
a 10.0 20.00
here is char here is char here is char
b 30.0 40.00
here is char here is char here is char
c 50.0 60.00
here is char here is char here is char
*/
DATA _NULL_;
  SET p;
  PUT x $ 5-10 @;            
  PUT @15 (y z)(4.3 "--" 2.);      
RUN;
/* 结果：
    a         10.0--20
    b         30.0--40
    c         50.0--60
*/
DATA _NULL_;
  SET p;
  PUT x =  @;            
  PUT @15 y = 4.3 @;
  PUT @25 Z = 2.;      
RUN;
/* 结果：
x=a           y=10.0    z=20
x=b           y=30.0    z=40
x=c           y=50.0    z=60
*/

DATA putmix;
  INPUT x $ y z m n p q;
  CARDS;
  x 10 20 30 40 50 60
  y 70 80 90 100 110 120
  ;
RUN;
DATA _NULL_;
  SET putmix;
  PUT @2 x$ @;            
  PUT y 5-10 .2 @;
  PUT @15 Z : 5.3@;
  PUT (m n p)(best10. "--" 4.2 "---" 4.2) @;
  PUT @60 q = ;     
RUN;
/* 结果：
x   10.00    20.00         30--40.0---50.0                q=60
y   70.00    80.00         90-- 100--- 110                q=120
*/


* FILE用法：规定当前的外部输出文件，与PUT配合使用，同一个DATA步可以使用多个FILE语句;
FILENAME files 'd:\utf.txt';
DATA _NULL_;
  SET a;
  FILE files ENCODING = 'utf-8';
  PUT name chinese_score;
RUN;

FILENAME files 'd:\filename.txt';    * 把abc输入文件，把文件名输入filed表。;
DATA filed;
  length temp $50;
  FILE files filename=temp;
  put 'abc';
  fname = temp;
RUN;

DATA d;
  LENGTH name $200;
  INPUT name;                                     * 从下述CARDS出读取内容到变量NAME中;
  NAME = 'd:\utf' || STRIP(_INFILE_) ||'.txt';    * _INFILE_是SAS的自动变量，表示读入当前读入的值，可以理解为自动变量_N_对应的观测;
  FILE anyname FILEVAR = NAME;
  date = DATE();                                  * 变量date和n录入表d;
  n=name;
  FORMAT DATE YYMMDD10.;
  DO;
    PUT 'TEST' @;
    PUT ',' @;
    PUT date;
  END;
  CARDS;
  test_file1
  test_file2
  test_file3
  ;
RUN;

DATA _NULL_;
  SET SASHELP.CLASS(KEEP name sex) NOBS = obs END = last;
  date = DATE();
  FILE 'd:\aaa.txt' DROPOVER LRECL=32767;
  IF _N_ = 1 THEN DO;                     * 如果是数据集第一行，则先输出header、日期、行数至文件;
    PUT 'header' @;
    PUT date @; FORMAT date yymmdd10.;
    PUT obs z8.;
  END;
  DO;
    PUT name $1-10 @;                     * 将数据集中name、sex的内容输出至文件;
    PUT sex $10-16;
  END;
  IF last THEN DO;                        * 如果是数据集最后一行，输出end至文件;
    PUT 'end';
  END;
RUN;

* LOG窗口输出控制;
PROC PRINTTO log = "d:\log.txt" NEW;     * 将日志窗口内容输出到文件，NEW表示替换源文件，如果追加就不要NEW;
PROC PRINT DATA = sashelp.class;         * 打印表内容;
PROC PRINTTO;                            * 恢复默认输出到日志窗口的状态;
RUN;

* OUTPUT窗口输出控制;
FILENAME routed "d:\result.txt";
PROC PRINTTO print=routed NEW;
RUN;
PROC FREQ DATA = sashelp.class;
	TABLES sex;
RUN;
PROC PRINTTO; 
RUN;

* ODS输出控制,通常DATA步和PRINTTO过程步主要输出文本文件，其余形式文件需要用ODS;
ODS LISTING CLOSE;                       * 关闭默认输出管道LISTING，否则输出结果同事在OUTPUT窗口显示;
ODS HTML file = "d:\test.html";          * 指定输出的目标文件，且是HTML格式;
PROC UNIVARIATE DATA = sashelp.class;    
	VAR weight;
RUN;
ODS HTML CLOSE;                          * 关闭HTML输出管道;
ODS LISTING;                             * 打开默认输出管道OUTPUT窗口;



*打印c9501的内容，
PROC PRINT DATA=c9501 NOOBS LABEL;  *NOOBS不显示观测序号，用字段的LABEL代替显示字段名
    VAR name chinese sex;  *只显示这3个变量
    WHERE name in ('李明','张聪');  *只分析李明、张聪的成绩
    LABEL name='姓名' math='数学成绩' chinese='语文成绩'; *为变量指定临时标签
    FORMAT math 5.1 chinese 5.1;                          *为变量输出指定格式
    BY name;                        *根据name值不同分页，类似于SQL的GROUP BY
    SUM chinese;                    *每一页中列出chinese成绩的汇总
RUN;    
    
*显示数据集bkmoney，并对amount字段求和显示
PROC PRINT data=bkmoney;
    SUM amount;
RUN;


*绘制散点图和曲线图
PROC GPLOT data=sasuser.gpa;
    SYMBOL i=none v=star;  *全程语句，指定绘图用的连线方式、颜色、散点符号、大小等
    PLOT satv*satm;  --指定绘图用的变量
RUN;

*绘制直方图和扇形图
PROC GCHART data=sasuser.gpa;
    VBAR gpa / group=sex;         *按性别分组绘制
    PIE sex / type=percent;       *绘制表示频数的扇形图，显示百分比
    BLOCK style / group=bedrooms; *绘制三维直方图
RUN;

*绘制3D曲面图
PROC G3D data=sasuser.gpa;
    PLOT x*y=z; --绘制三维直方图
RUN;
*根据三维模型绘制等高线图
PROC GCONTOUR data=dnorm2;
    PLOT x*y=z / nolegend autolabel;
RUN;

*图形的输出格式调整
GOPTIONS FTEXT="宋体" HTITLE=2 cells HTEXT=1 cells;


/*格式化打印
--例如源文件Cars.dat数据如下：
-- 19 1 14000 Y
-- 45 1 65000 G
-- 72 2 35000 B
-- 31 1 44000 Y
-- 58 2 83000 W
*/
DATA carsurvey;
    INFILE 'c:\MyRawData\Cars.dat';
    INPUT Age Sex Income Color $;
PROC FORMAT;
    VALUE gender 1 = 'Male'
                 2 = 'Female';
    VALUE agegroup 13 -< 20 = 'Teen'
                   20 -< 65 = 'Adult'
                   65 - HIGH = 'Senior';
    VALUE $col 'W' = 'Moon White'
               'B' = 'Sky Blue'
               'Y' = 'Sunburst Yellow'
               'G' = 'Rain Cloud Gray';
* Print data using user-defined and standard (DOLLAR8.) formats;
PROC PRINT DATA = carsurvey;
    FORMAT Sex gender. Age agegroup. Color $col. Income DOLLAR8.;
TITLE 'Survey Results Printed with User-Defined Formats';
RUN;
/*打印结果如下：
    Survey Results Printed with User-Defined Formats 1
 Obs Age    Sex    Income  Color
 1   Teen   Male   $14,000 Sunburst Yellow
 2   Adult  Male   $65,000 Rain Cloud Gray
 3   Senior Female $35,000 Sky Blue
 4   Adult  Male   $44,000 Sunburst Yellow
 5   Adult  Female $83,000 Moon White
*/

*若表格中有字段为字符型，则列出所有记录
PROC REPORT DATA = natparks NOWINDOWS HEADLINE HEADSKIP;
    TITLE 'Report with Character and Numeric Variables';
RUN;
*若表格中全部为数字型，则只列出每个字段的汇总值
PROC REPORT DATA = natparks NOWINDOWS HEADLINE HEADSKIP;
    COLUMN Region Name Museums Camping;
    DEFINE Region / ORDER;                         *将Region列排序
    DEFINE Camping / ANALYSIS 'Camp/Grounds';      *将Camping列分析显示并重命名列为'Camp/Grounds'
    TITLE 'Report with Only Numeric Variables';
RUN;
/* DEFINE var /后面的选项可以是：
--ACROSS(creates a column for each unique value of the variable) 
--ANALYSIS(为某个字段生成统计值，默认是sum) 
--DISPLAY() GROUP() ORDER()
*/

*给表格增加汇总指标
PROC REPORT DATA = natparks NOWINDOWS HEADLINE;
    COLUMN Name Region Museums Camping;
    DEFINE Region / ORDER;                  *将Region列排序
    BREAK AFTER Region / SUMMARIZE OL SKIP; *在每个Region值后面增加汇总指标，SUMMARIZE累计，OL在break上面划条线，UL在break下面划条线，SKIP插入一条空行，PAGE在每个break后面新起一页
    RBREAK AFTER / SUMMARIZE OL SKIP;       *RBREAK只在报表最后增加汇总指标
    TITLE 'National Parks';
RUN;

*给表格增加其他统计指标
Dinosaur              NM West 2 6
Ellis Island          NM East 1 0
Everglades            NP East 5 2
Grand Canyon          NP West 5 3
Great Smoky Mountains NP East 3 10
Hawaii Volcanoes      NP West 2 2
Lava Beds             NM West 1 1
Statue of Liberty     NM East 1 0
Theodore Roosevelt    NP .    2 2
Yellowstone           NP West 9 11
Yosemite              NP West 2 13

DATA natparks;
    INFILE 'c:\MyRawData\Parks.dat';
    INPUT Name $ 1-21 Type $ Region $ Museums Camping;
*Statistics in COLUMN statement with two group variables;
PROC REPORT DATA = natparks NOWINDOWS HEADLINE;
    COLUMN Region Type N (Museums Camping),MEAN;   *将Museums和Camping计算平均值列出
    DEFINE Region / GROUP;                         *根据Region做GROUP处理
    DEFINE Type   / GROUP;                         *根据Region做GROUP处理
    TITLE 'Statistics with Two Group Variables';
RUN;
*Statistics in COLUMN statement with group and across variables;
PROC REPORT DATA = natparks NOWINDOWS HEADLINE;
    COLUMN Region N Type,(Museums Camping),(MIN MAX);  *将Museums和Camping计算MIN、MAX值列出
    DEFINE Region / GROUP;
    DEFINE Type / ACROSS;
    TITLE 'Statistics with a Group and Across Variable';
RUN;       
/*COLUMN中可以使用的统计值：
MAX,MIN
MEAN算术平均
MEDIAN中位数
N number of non-missing values
NMISS字段值为空的个数
P90 the 90th percentile
PCTN the percentage of observations for that group
PCTSUM the percentage of a total sum represented by that group
STD the standard deviation
SUM the sum       
*/       
       
*导出数据
PROC EXPORT DATA = hotels OUTFILE = 'c:\MyRawData\Hotels.csv' REPLACE DBMS = DLM REPLACE;
    DELIMITER='&';



/**********Output Delivery System**********/

*指定输入格式
PROC TEMPLATE;
    LIST STYLES;
RUN;
/*可用的模式：
LISTING standard SAS output
OUTPUT SAS output data set
HTML Hypertext Markup Language
RTF Rich Text Format
PRINTER high resolution printer output1
PS PostScript
PCL Printer Control Language
PDF Portable Document Format
MARKUP markup languages including XML
DOCUMENT output document
*/

*指定是否将输入结果放入SAS日志
DATA giant;
    INFILE 'c:\MyRawData\Tomatoes.dat' DSD;
    INPUT Name :$15. Color $ Days Weight;
* Trace PROC MEANS;
ODS TRACE ON;
PROC MEANS DATA = giant;
    BY Color;
RUN;
ODS TRACE OFF;

*将输出结果的指定部分显示出来
PROC MEANS DATA = giant;
    BY Color;
    TITLE 'Red Tomatoes';
    ODS SELECT Means.ByGroup1.Summary;
RUN;

*把PORC TABULATE出来的结果输出至数据集tabout
PROC TABULATE DATA = giant;
    CLASS Color;
    VAR Days Weight;
    TABLE Color ALL, (Days Weight) * MEAN;
    TITLE 'Standard TABULATE Output';
ODS OUTPUT Table = tabout;
RUN;

*把数据集输出至html文件
ODS HTML BODY = 'c:\MyHTMLFiles\MarineBody.html'
    CONTENTS  = 'c:\MyHTMLFiles\MarineTOC.html'
    PAGE      = 'c:\MyHTMLFiles\MarinePage.html'
    FRAME     = 'c:\MyHTMLFiles\MarineFrame.html';
DATA marine;
    INFILE 'c:\MyRawData\Sealife.dat';
    INPUT Name $ Family $ Length @@;
PROC MEANS DATA = marine;
    CLASS Family;
    TITLE 'Whales and Sharks';
PROC PRINT DATA = marine;
RUN;
* Close the HTML files;
ODS HTML CLOSE;

  
*把数据集输出至html文件  
* Create an RTF file;
ODS RTF FILE = 'c:\MyRTFFiles\Marine.rtf' BODYTITLE;
DATA marine;
    INFILE 'c:\MyRawData\Sealife.dat';
    INPUT Name $ Family $ Length @@;
PROC MEANS DATA = marine;
    CLASS Family;
    TITLE 'Whales and Sharks';
PROC PRINT DATA = marine;
RUN;
* Close the RTF file;
ODS RTF CLOSE;

*把数据集输出至PDF等文件用于高分辨率打印  
* Create the PDF file;
ODS PRINTER/PCL/PostScript/PDF FILE = 'c:\MyPDFFiles\Marine.pdf';
DATA marine;
    INFILE 'c:\MyRawData\Sealife.dat';
    INPUT Name $ Family $ Length @@;
PROC MEANS DATA = marine;
    CLASS Family;
    TITLE 'Whales and Sharks';
PROC PRINT DATA = marine;
RUN;
* Close the PDF file;
ODS PDF CLOSE;

*制定标题和页脚格式TITLE和FOOTNOTES
TITLE COLOR=BLACK 'Black ' COLOR=GRAY 'Gray ' COLOR=LTGRAY 'Light Gray';
TITLE HEIGHT=12pt 'Small ' HEIGHT=.25in 'Medium ' HEIGHT=1cm 'Large';
TITLE JUSTIFY=LEFT 'Left ' JUSTIFY=CENTER 'vs. ' JUSTIFY=RIGHT 'Right';
TITLE 'Default ' FONT=Arial 'Arial ' FONT='Times New Roman' 'Times New Roman ' FONT=Courier 'Courier';
TITLE FONT=Courier 'Courier ' BOLD 'Bold ' BOLD ITALIC 'Bold and Italic';
/*可用的选项：
COLOR= specifies a color for the text
BCOLOR= specifies a color for the background of the text
HEIGHT= specifies the height of the text
JUSTIFY= requests justification
FONT= specifies a font for the text
BOLD makes text bold
ITALIC makes text italic
*/

*用特定格式显示数据集
PROC PRINT/REPORT/TABULATE STYLE(DATA) = {BACKGROUND = pink};
/*其中STYLE括号中表示数据集的位置，可以是DATA/HEADER/OBS/OBSHEADER/TOTAL/GRANDTOTAL，一个PRINT子句可以包括多个STYLE选项。
{}部分选项：BACKGROUND/FONT_STYLE/FONT_WEIGHT*/

*条件格式
ODS HTML FILE='c:\MyHTML\mens2.html';
PROC FORMAT;
    VALUE rec 
        0 -< 378.72 ='red'
        378.72 -< 382.20 = 'orange'
        382.20 - HIGH = 'white';
PROC PRINT DATA=results;
    ID Place;
    VAR Name Country;
    VAR Time/STYLE={BACKGROUND=rec.};
    TITLE 'Men''s 5000m Speed Skating';
    TITLE2 '2002 Olympic Results';
RUN;
ODS HTML CLOSE;  




