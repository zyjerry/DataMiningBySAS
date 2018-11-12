/****************  SAS宏  ****************/
* 定义宏变量;
%LET m_value = newdata;
%LET m_value = 3;
* 显示宏变量;
%PUT &m_value;
%PUT here is &m_value;
* 引用宏变量;
%LET x = 30;
DATA a;
	X = &x.;
RUN;

%LET var = ddd;
DATA a;
	X = "here is &var .";             * 必须用双引号引用鸿变量，而不能用单引号;
RUN;

%LET mvar = here;          * 隔离鸿变量和后面文本，用空格、句点均可;
%PUT &mvar.100;
%PUT &mvar 100;
%PUT &mvar..txt;

%LET mvar = here;          * 引用两个宏变量;
%LET x = 10;          
%PUT &&mvar.&x;


* 定义宏程序;
%MACRO dsn;
	……
%MEND dsn;

* 一个宏可以嵌套调用另一个宏;
%MACRO prt;
	……
%MEND prt;
%MACRO dsn;
	%prt;
%MEND dsn;

* 创建永久存储的宏，编译完下述宏后，会发现系统磁盘下有一个名sasmacr的文件，只能在SAS系统下打开;
LIBNAME test 'f:\data_model\chapt10';
OPTIONS MSTORED SASMSTORE = test;
%MACRO test /store;
	OPTIONS NOPRINT NOSOURCE;     * 增加NOPRINT NOSOURCE后，在SAS下无法破译，但仍可用C语言反编译;
	……
%MEND test;
* 调用永久存储的宏;
LIBNAME test 'f:\data_model\chapt10';
OPTIONS MSTORED SASMSTORE = test;
%test;

* 按值创建宏参数;
%MACRO value(x=, y=);
	DATA test;
		x=&x.;
		y=&y.;
	RUN;
%MEND value;
%value(x=1,y=2);

* 按址创建宏参数;
%MACRO value(x, y);
	DATA test;
		x=&x.;
		y=&y.;
	RUN;
%MEND value;
%value(1,2);

* 通配函数;
%LET num = 10;
%LET x = %SYSFUNC(TRIM(%SYSFUNC(LEFT(&num))));
%PUT &x;






/**********SAS宏**********/
%LET thedat=sasuser.class;
--调用宏
&thedat.

%MACRO 宏名(参数表);
……
%MEND 宏名;
--调用宏
%宏名(参数表)

--例1：
%LET flowertype = Ginger;
DATA flowersales;
    INFILE 'c:\MyRawData\TropicalSales.dat';
    INPUT CustomerID $ @6 SaleDate MMDDYY10. @17 Variety $9. Quantity;
    IF Variety = ”&flowertype”;
PROC PRINT DATA = flowersales;
    FORMAT SaleDate WORDDATE18.;
    TITLE ”Sales of &flowertype”;
RUN;

--例2：
%MACRO sample;
    PROC SORT DATA = flowersales;
        BY DESCENDING Quantity;
    PROC PRINT DATA = flowersales (OBS = 5);
        FORMAT SaleDate WORDDATE18.;
        TITLE 'Five Largest Sales';
%MEND sample;

DATA flowersales;
    INFILE 'c:\MyRawData\TropicalSales.dat';
    INPUT CustomerID $ @6 SaleDate MMDDYY10. @17 Variety $9. Quantity;
RUN;
%sample
RUN;

--例3：
%MACRO select(customer=,sortvar=);
    PROC SORT DATA = flowersales OUT = salesout;
    BY &sortvar;
    WHERE CustomerID = ”&customer”;
    PROC PRINT DATA = salesout;
    FORMAT SaleDate WORDDATE18.;
    TITLE1 ”Orders for Customer Number &customer”;
    TITLE2 ”Sorted by &sortvar”;
%MEND select;
DATA flowersales;
    INFILE ’c:\MyRawData\TropicalSales.dat’;
    INPUT CustomerID $ @6 SaleDate MMDDYY10. @17 Variety $9. Quantity;
RUN;
%select(customer = 356W, sortvar = Quantity)
%select(customer = 240W, sortvar = Variety)
RUN;

--例4：
%MACRO dailyreports;
    %IF &SYSDAY = Monday %THEN %DO;
        PROC PRINT DATA = flowersales;
        FORMAT SaleDate WORDDATE18.;
        TITLE 'Monday Report: Current Flower Sales';
    %END;
    %ELSE %IF &SYSDAY = Tuesday %THEN %DO;
        PROC MEANS DATA = flowersales MEAN MIN MAX;
        CLASS Variety;
        VAR Quantity;
        TITLE 'Tuesday Report: Summary of Flower Sales';
    %END;
%MEND dailyreports;

DATA flowersales;
    INFILE 'c:\MyRawData\TropicalSales.dat';
    INPUT CustomerID $ @6 SaleDate MMDDYY10. @17  Variety $9. Quantity;
RUN;
%dailyreports
RUN;

--例5：
DATA flowersales;
    INFILE 'c:\MySASLib\TropicalSales.dat';
    INPUT CustomerID $4. @6 SaleDate MMDDYY10. @17 Variety $9. Quantity;
PROC SORT DATA = flowersales;
    BY DESCENDING Quantity;

DATA _NULL_;
    SET flowersales;
    IF _N_ = 1 THEN CALL SYMPUT(”selectedcustomer”,CustomerID);    *把第一行的CustomerID值赋给宏变量selectedcustomer;         
    ELSE STOP;
PROC PRINT DATA = flowersales;
    WHERE CustomerID = ”&selectedcustomer”;
    FORMAT SaleDate WORDDATE18.;
    TITLE ”Customer &selectedcustomer Had the Single Largest Order”;
RUN;

--例7：
%MACRO calculate(N);
    %do i=1 %to &n;   
        %let j=  PUT(&i.,z2.);
        DATA WORK.aaa_&i.;
            SET cdmbdatc.BDL_COM_G_CHN_MAPPING;
            WHERE business_series_cd=&j. ;
        RUN;
    %end;
%mend calculate;

--例8：循环调用宏
%MACRO huangshiren(fengjie);
%put &fengjie.，这是为什么呢~~~;
%put                          ;
%mend;

DATA _NULL_;
    format yiren $100. ;
    do yiren='亲爱的','五花肉','正太哥','强哥','Honey~','傻瓜','蜜糖','果脯','五毛','美狗','郎教授','如花','年轻人 May the force be with you','招行行长：房价上涨是因为老百姓钱太多了','巴菲特看到我国的物价发展水平也会哭~';
        CALL EXECUTE('%huangshiren('||yiren||');');
    END;
RUN;
