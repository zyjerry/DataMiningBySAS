
* TABULATE:分组统计数据集表格展示;
PROC TABULATE data= c9501bk FORMAT=COMMA10.0;  *用COMMA10.0的格式统一显示单元格
    CLASS sex;
    VAR math chinese;
    TABLE sex ALL, (math chinese)*(MEAN STD) 
    /BOX='Full Day Excursions' MISSTEXT='none';  *BOX=可以在表格左上角标注默认文本，MISSTEXT=可以在空的单元格里标注默认文本
    keylabel mean='平均值' std='标准差' all='总计';
    label sex='性别' math='数学' chinese='语文';
RUN;
/* 其中TABLE选项的统计量名还可以是：
   N(非空值数量),NMISS(空值数量), MEAN, STD, MIN, MAX, RANGE, SUM, USS, CSS, STDERR, CV, 
   T(检验值均为0的t统计量值),PRT(t统计量的p值), VAR, SUMWGT(权数变量的和), PCTN(某类观测占总观测个数的百分比), PCTSUM(某类观测的总和占全部总和的百分比）    
*/

* 分组统计数据集表格展示;
DATA boats;
    INFILE 'c:\MyRawData\Boats.dat';
    INPUT Name $ 1-12 Port $ 14-20 Locomotion $ 22-26 Type $ 28-30
    Price 32-36 Length 38-40;
    * Using the FORMAT= option in the TABLE statement;
PROC TABULATE DATA = boats;
    CLASS Locomotion Type;
    VAR Price Length;
    TABLE Locomotion ALL,
    MEAN * (Price*FORMAT=DOLLAR6.2 Length*FORMAT=6.0) * (Type ALL);  --以不同格式展示不同维度;
    TITLE 'Price and Length by Type of Boat';
RUN;


* SORT：对数据集排序;
PROC SORT DATA=c9501 OUT = neat NODUPKEY;  *NODUPKEY表示去掉BY字段重复的记录，OUT表示生成新的数据集;
    BY sex DESCENDING avg;  *如果不指定排序变量名，还可以泛指_ALL_, _CHARACTER_, _CHAR_, _NUMERIC_;
RUN;

* 统计数据集中变量的统计量;
PROC MEANS/MAX/MIN/MEDIAN/N/NMISS/RANGE/STDDEV/SUM data=c9501 NOPRINT;  *NOPRINT表示不用把结果打印出来;
    VAR   math chinese;  *统计哪些字段，缺失的话就统计所有字段;
    BY    math chinese;  *单独分析某些字段;
    CLASS math chinese;  *功能同BY，但输出显示更紧凑;
RUN;


* UNIVARIATE：统计某个变量的分布情况，包括上述各种统计量;
PROC UNIVARIATE data=c9501 PLOT;   *PLOT选项增加绘图
    VAR math chinese;
    OUTPUT out=a pctlpre=p pctlpts=(20 40 60 80 );   *可选，指定特定的百分位;
RUN;
*也可以集中写成;
PROC MEANS DATA=c9501 N MEAN MEDIAN STD Q1 Q3 QRANGE MAXDEC=2;  *指定小数点后2位，同时计算样本量、平均值、中位数、标准差、Q1、Q3、Q1和Q3的范围;
  VAR testscore;
  TITLE '*******';
RUN;

* FREQ：统计离散变量的统计量;
PROC FREQ data=c9501;
    TABLES sex / LIST/MISSING/NOCOL/NOROW/OUT=……;  */后面是选项，LIST列表形式，MISSING统计包括空值，OUT写入数据集;
RUN;




* CORR：计算变量的相关系数，测算变量hsm hss hse和变量score的相关性;
PROC CORR DATA=SASUSER.GPA;
    VAR hsm hss hse;
    WITH Score;
RUN;



* REG：回归分析;
DATA hits;
    INFILE 'c:\MyRawData\Baseball.dat';
    INPUT Height Distance @@;
PROC REG DATA = hits;
    MODEL Distance = Height;                 *Distance是应变量，Height是主变量;
    PLOT Distance * Height;
    TITLE 'Results of Regression Analysis';
RUN;
/*源数据：
50 110 49 135 48 129 53 150 48 124
50 143 51 126 45 107 53 146 50 154
47 136 52 144 47 124 50 133 50 128
50 118 48 135 47 129 45 126 48 118
45 121 53 142 46 122 47 119 51 134
49 130 46 132 51 144 50 132 50 131
*/



* 简单无重复随机抽样;
DATA smp;
	SET sashelp.class;
	rdm = UNIFORM(0);                  * 先随机生成数字;
RUN;
PROC SORT DATA = smp; BY rdm;        * 根据随机数排序;
RUN;
DATA out_smp;                        * 取部分数据;
	SET smp;
	IF _N_ LE 10;
RUN;

PROC SURVEYSELECT DATA = sashelp.class OUT = b NOPRINT SAMPSIZE = 10; * 按样本数抽取;
PROC SURVEYSELECT DATA = sashelp.class OUT = b NOPRINT SAMPRATE = 0.3; * 按样本比例抽取;
RUN;

* 分层等比例随机抽样;
PROC SORT DATA=sashelp.class OUT = class;
	BY sex;
RUN;
PROC SURVEYSELECT 
	DATA = class NOPRINT METHOD = srs RATE = 0.5 OUT = outclass;
		strata sex;
RUN;



* SURVEYSELECT：随机抽样;
PROC SURVEYSELECT DATA=cdmpdats.DML_CVM_PROD_DISTRIBUTE() 
	OUT=WORK.aaa
	METHOD=SRS
	N=1000000;
RUN;

