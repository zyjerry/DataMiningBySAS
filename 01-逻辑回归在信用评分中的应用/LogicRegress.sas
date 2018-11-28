/*  0.前言：  
    数据挖掘项目最繁琐且最不可自动化的环节在前期数据清洗，所以本程序不做演示和赘述。
    已经有一份处理好的宽表数据pf_data1（见本目录下SAS数据文件pf_data1.sas7bdat）：
    loan_id为流水号，y是因变量（其中y=1表示坏客户），其余均为自变量。
    本程序着重演示如何选取有效自变量、如何建模、如何制定评分标准；
    为使程序更加自动化、简洁优雅，用到了宏程序，如果能掌握其中含义，大概能应付80%的建模应用场景吧。。。手动挖鼻。。。
    有了原始宽表数据和本程序，只消修改第9、10行的目录为实际目录，即可一路通畅执行到底，无毒无副作用，请放心食用。
 */
%LET basedir = "E:\";    * 基础逻辑库，原始宽表和脚本建议都放在这里 ;
%LET scorefile = "E:\score";  * 存放分数计算公式的文件名，建议和逻辑库放一起 ;
LIBNAME sqpf &basedir.;  * 将sas数据文件pf_data1放入指定目录库，并指定逻辑库为该目录，就能直接看到数据文件 ;

/*  1.对城市聚类：本案例中，城市字段city_name有300个左右，需分组。
    总体分组策略是：先计算响应概率，即每个城市的坏客户占比，再根据响应概率用聚类方式确定分组数量和分组。 
    其实也没必要非要用聚类算法，根据相应概率简单粗暴划几个档也是可以的，这里就是小装个逼。。。手动挖鼻。。。
 */

/*  1.1计算响应概率  */
PROC MEANS 
    DATA = sqpf.pf_data1 NOPRINT NWAY;
    CLASS city_name;
    VAR y;
    OUTPUT OUT = level MEAN = prop;
RUN; 

/*  1.2对城市进行分层次的聚类  */
PROC CLUSTER 
    DATA = level METHOD = ward
    OUTTREE = fortree;
    FREQ _freq_;  
    VAR prop;  
    ID city_name;
RUN;

/*  1.3分析结果表fortree，R方和半偏R方相对较稳定理想值的切在9类，则后续按照9类为标准做快速聚类。
    为什么不直接用层次聚类的结果呢。。。因为。。。还没有搞懂怎么直接导出分类结果。。。手动摊手。。。
    理论上肯定是有办法的。。。这里先偷个懒。。。
  */
PROC FASTCLUSTER 
    DATA= level OUT=clust MAXC=9 CLUSTER=cluster MAXITER=99;
    VAR prop;  
    ID city_name;
    ODS LISTING;
RUN;

/*  1.4分析结果表clust，把freq少于10且prop<0.1的城市，都分到中档次，这部分城市的记录数较少，随机性太高，不宜给予较高得分  */
PROC SQL NOPRINT; 
    UPDATE clust SET cluster=6 WHERE _freq_<10 AND prop<0.1;
QUIT;


/*  1.5将快速聚类结果表clust合并到原始宽表，形成新的完整的宽表  */
PROC SORT DATA = sqpf.pf_data1;
	  BY city_name;
PROC SORT DATA = clust;
	  BY city_name;
RUN;
DATA sqpf.pf_data2;
	  MERGE sqpf.pf_data1 clust;
	  BY city_name;
	  city_cluster = COMPRESS('C'||cluster);
	  DROP _TYPE_ _FREQ_ prop cluster DISTANCE; 
	  applied_term_char = PUT(applied_term,z2.);    * applied_term字段导入时为数字型，不利于后续分类关联操作，先转换成字符型;
RUN;

DATA sqpf.pf_data2;
	  SET sqpf.pf_data2;
	  * applied_term已被字符型applied_term_char替代，就可以删除了，city_name已经被聚类操作过了，用city_cluster替代，也可以删除了;
	  DROP applied_term city_name registered_city residential_city;     
RUN;


/*  2.至此，pf_data2可以作为基础宽表作进一步分析，分析每个字段的显著性，筛选入模变量  */

/*  2.1宏函数：计算每个变量值的WOE    */
%MACRO calculate_woe();
    PROC SQL NOPRINT;
        SELECT SUM(y) , SUM(CASE WHEN y=0 THEN 1 ELSE 0 END) INTO : var_b, :var_g FROM  sqpf.pf_data2;
    QUIT;
    %PUT &var_b;
    %PUT &var_g;
    
	  * 如果存在pf_woe这张表，就先删除它，再重建一张空表，用于存放每个变量的woe值;
    %IF %SYSFUNC(EXIST(pf_woe)) NE 0 %THEN %DO;
        PROC DATASETS LIB=work NOLIST;
        DELETE pf_woe;
        QUIT; 
        DATA pf_woe;
        LENGTH columnname $32 columnvalue $16 bi 8 gi 8 b 8 g 8 woe 4.4;
        STOP;
        RUN;
    %END;
    * 获取pf_data2中所有的自变量;
    PROC CONTENTS 
        DATA=sqpf.pf_data2(drop=loan_id y) 
        NOPRINT OUT=origin_dev_variable;
    RUN;
    * 循环计算每个变量woe值，全部记入pf_woe表中 ;
    %LET dsid=%SYSFUNC(OPEN(origin_dev_variable));               * 打开origin_dev_variable表，即需要分析的变量;
    %IF &dsid GT 0 %THEN %DO;
        %LET nobs=%SYSFUNC(ATTRN(&dsid,nobs));                   * 获取需要分析的变量列表;
        %DO i=1 %TO &nobs;
            %LET rc=%SYSFUNC(FETCHOBS(&dsid,&i));                * 游标定位;
            %LET varnume=%SYSFUNC(VARNUM(&dsid,NAME));           * 获取NAME字段所在位置;
            %LET variable=%SYSFUNC(GETVARC(&dsid,&varnume));     * 获取变量名称;
            
            DATA temp1;
            	  SET sqpf.pf_data2;
            	  KEEP loan_id  &variable. y;
            RUN;
            
            PROC SORT DATA = temp1;
            	  BY &variable.;
            RUN;
            * 计算每个变量值的woe ;
            DATA temp2;
            	  SET temp1(KEEP =  &variable. y );
            	  BY  &variable.;
            	  RETAIN bi cny; 
                IF first.&variable. THEN DO;    * 如果是BY汇总后的第一条观测，则初始化各项变量;
                    cny = 0;
                    bi = 0;
                END;
                columnvalue = &variable.;
                bi + y;
                cny + 1;
                gi = cny - bi;
                b = &var_b.;
                g = &var_g.;
                IF bi=0 THEN woe = LOG((gi/g)/(1/b)); ELSE woe = LOG((gi/g)/(bi/b));    * 防止除数为0; 
                IF last.&variable.; 
            RUN;
            DATA temp3;
            	  columnname = "&variable.";
            	  SET temp2(KEEP = columnvalue bi gi b g woe);            	
            RUN;
            * 把每个变量值的woe追加到总表pf_woe中 ;
            PROC APPEND 
            	  base=pf_woe data=temp3 force;
            RUN ;
        %END;
        %LET dsid=%SYSFUNC(CLOSE(&dsid));
    %END;
%MEND calculate_woe;

* 调用宏;
%calculate_woe;


/*  2.2剔除每个字段值WOE出现NULL的情况  */
PROC SQL NOPRINT; 
    DELETE FROM pf_woe WHERE woe IS NULL;
QUIT;

/*  2.3计算每个字段的IV值并且只保留IV值>=0.019的字段  */
PROC SQL NOPRINT; 
    CREATE TABLE pf_iv AS 
    SELECT columnname, SUM((gi/g-bi/b)*woe) AS iv 
    FROM pf_woe GROUP BY columnname HAVING SUM((gi/g-bi/b)*woe) >= 0.019;
QUIT;

PROC SORT DATA = pf_iv;
	  BY DESCENDING iv ;
RUN;

/*  2.4将原始宽表字段值替换为woe值  */
PROC SQL NOPRINT;   * 先把要计算的变量名称定好 ;
	  SELECT columnname,'woe_'||columnname||' FORMAT=8.4' INTO : vars SEPARATED BY ' ', : woevars SEPARATED BY ' ' FROM pf_iv;
QUIT;
DATA sqpf.pf_data3; * 记录woe的字段追加到pf_data3中，初始化为空 ;
	  SET sqpf.pf_data2 (KEEP = &vars. loan_id y );
	  ATTRIB &woevars.;
RUN;

%MACRO replace_woe();  * 填入事前计算好的woe值 ;
    %LET dsid=%SYSFUNC(OPEN(pf_iv));               * 打开pf_iv表，即需要替换的变量;
    %IF &dsid GT 0 %THEN %DO;
        %LET nobs=%SYSFUNC(ATTRN(&dsid,nobs));                   * 获取需要分析的变量列表;
        %DO i=1 %TO &nobs;
            %LET rc=%SYSFUNC(FETCHOBS(&dsid,&i));                * 游标定位;
            %LET varnume=%SYSFUNC(VARNUM(&dsid,columnname));     * 获取NAME字段所在位置;
            %LET variable=%SYSFUNC(GETVARC(&dsid,&varnume));     * 获取变量名称;
            
            PROC SQL NOPRINT;
                UPDATE sqpf.pf_data3 a 
                SET woe_&variable. = (SELECT woe FROM pf_woe b WHERE columnname = "&variable." AND columnvalue = a.&variable.);
            QUIT;
        %END;
        %LET dsid=%SYSFUNC(CLOSE(&dsid));
    %END;
%MEND replace_woe;

* 调用宏;
%replace_woe;


/*  3.逻辑回归  
    选取IV值>0.19的字段，作为模型自变量。
    pf_data3导入SAS做逻辑回归，residential_city、registered_city除外，这里城市太琐碎且与city_name重复 。
    city_cluster 城市聚类
    yixin_weiyuegailv 宜信违约概率
    first_credit_card_months 信用卡首次申请距今月数
    applied_product  申请产品
    yixin_loan  宜信是否有借款
    personal_check_times 个人查询次数
    company_property 单位性质
    applied_term 申请期限
    payroll_form 发薪方式
    credit_card_cmt 信用卡总授信额度
    credit_card_used_amt 信用卡已用额度
    address_living_months 来本市居住月数
    education_level 教育
    credit_per_amt 信用卡平均单张授信额度
    applied_amount 申请金额
    gender 性别
    credit_card_usage 信用卡负债率
    marital_status 婚姻

*/
/*  3.1 获取pf_data2中所有的自变量  */
PROC CONTENTS 
    DATA=sqpf.pf_data3(drop=loan_id y) 
    NOPRINT OUT=origin_dev_variable;
RUN;
DATA origin_dev_variable;
	  SET origin_dev_variable(KEEP = NAME);
	  IF  INDEX(NAME,"woe_") = 1;
RUN;
PROC SQL NOPRINT;
	  SELECT NAME INTO : vars SEPARATED BY ' ' FROM origin_dev_variable;
QUIT;
%PUT &vars.;
/*  3.2 逻辑回归运行出来AUC是0.76，这里参数SLE=0.05是默认情况， SLS=0.01比默认值0.05要严格一些  */
PROC LOGISTIC DATA = sqpf.pf_data3 DESC OUTEST=model_params;
    MODEL y = &vars.  
         /SELECTION=STEPWISE SLE=0.05 SLS=0.01 OUTROC=roc RSQ;
    OUTPUT OUT=pred_probs  P=pred_response;
RUN;


/*  4. 转换为评分结果  
    SCORE = factor * L + offset 
    分数基础值设为500分，PD0:50分翻倍，ods=1/5
    factor * ln(1/5) + offset =500
    factor * ln(1/10) + offset =550
    解得：factor = 50/(ln(1/10) - ln(1/5)) = 50/ln(1/2)= -72.1348，  offset = 500+72.1348* ln(1/5) = 383.9
*/
/*  4.1 先把上一步建模中的似然函数拎出来  */
PROC TRANSPOSE DATA=model_params OUT=independent;
RUN;

DATA independent;
	  SET independent (RENAME = ( _NAME_= columnname ) );
    WHERE y NE . AND columnname NE '_LNLIKE_' ;
RUN;

/*  4.2 把评分公式写到文件score中  */
%MACRO score_file_out();
    FILENAME score &scorefile.;
    DATA _NULL_;
        SET independent END=last;
        FILE score ;
        IF _N_=1 THEN DO;
        	  PUT @1 "score = &factor. * ( ";       	
        END;
        
        IF columnname ='Intercept' THEN DO;
        	  PUT @1 "+" @;
        	  PUT @5 "(" y 10.5 ")";
        END;
        ELSE DO; 
        	  PUT @1 "+" @;
        	  PUT @5 '(' y best10. @20 '* ' columnname $32. ')';
        END;
        
        IF LAST THEN DO;
        	  PUT ") + &offset. ;";
        END;
    RUN;
%MEND score_file_out;

%score_file_out;


/*  4.3 计算建模数据中的分数  */
%LET factor = -72.1348;
%LET offset = 383.9;
DATA sqpf.pf_data4;
	  SET sqpf.pf_data3;
	  %INCLUDE &scorefile.;
	  score_round = ROUND(score);
RUN;



/*  5.根据pf_woe，把每个字段值对应为一个评分值，做成评分表。  */
PROC SQL NOPRINT;
	  SELECT COUNT(*)-1 INTO : n FROM independent;
	  SELECT y INTO : intercept FROM independent WHERE columnname = 'Intercept';
QUIT;

PROC SORT 
	  DATA = pf_woe; 
	  BY columnname; 
RUN;
PROC SORT 
	  DATA = independent; 
	  BY columnname; 
RUN;
DATA sqpf.pf_woe_score;
	  MERGE pf_woe independent;
	  BY columnname;
	  DROP _LABEL_;
	  score = &factor.*woe*y + (&factor.* &intercept. + &offset.)/&n. ; 
	  score_round = ROUND(score); 
RUN;

DATA sqpf.pf_woe_score;
	  SET sqpf.pf_woe_score;
	  IF y NE .; 
RUN;



/*  6.验证评分结果按人数等分，这里计算出结果表后需导出值excel作图.
    理论上SAS绘图功能也是可以直接画的，只是本人尚未点亮这棵技能树。。。手动摊手。。。  
    */
/* 6.1 将评分结果按照分数值从低到高排序，均分为20组  */
PROC RANK 
    DATA = sqpf.pf_data4 groups=20 OUT=rankd ;
    VAR score_round;
    RANKS decile;
RUN;
PROC SORT 
    DATA=rankd;
    BY decile;
    LABEL  decile='decile';
RUN; 

PROC MEANS 
    DATA=rankd NOPRINT;
    VAR y ;
    CLASS decile;
    OUTPUT OUT=sumout n=count sum=asum;
RUN;

/*  6.2计算每组坏客户数以及占比，可再手工导出excel画坏占比趋势图  */
DATA sumout_final;
    SET sumout(keep=decile count asum );
    WHERE decile ne .;
    event_rate = asum / count;
    LABEL decile='decile' count='客户数' asum='坏客户数' event_rate='坏客户占本组比例' ;
RUN;


/*  7.验证评分结果按分数等分，这里计算出结果表后需导出值excel作图，理论上SAS绘图功能也是可以直接画的，只是本人尚未点亮这棵技能树。。。手动摊手。。。  */
PROC SQL NOPRINT;
    SELECT MIN(score_round), (MAX(score_round)-MIN(score_round))/20 into :min_score, :decile_20 FROM rankd;
QUIT;
%PUT &min_score &decile_20;

DATA rankd;
	  SET rankd;
	  decile_by_score = FLOOR((score_round-&min_score)/ROUND(&decile_20,0));
RUN;

PROC MEANS DATA=rankd  N SUM MIN MAX NOPRINT;
    VAR y score_round;
    CLASS decile_by_score ;
    OUTPUT OUT=sumout_by_score  N=count SUM=asum ssum MIN= ymin smin MAX=ymax smax ;
RUN;

DATA sumout_by_score;
	  SET sumout_by_score(KEEP = decile_by_score count asum smin smax);
	  WHERE decile_by_score ne .;
    event_rate = asum / count;
	  bsum=count-asum;
	  cha = smax - smin;
    LABEL count='客户数' asum='坏客户数' bsum='好客户数' event_rate='坏客户占本组比例' ;
RUN;

PROC SQL NOPRINT;
    SELECT sum(count),sum(asum),sum(bsum) into: mc_cnt, :mc_event, :mc_good FROM sumout_by_score;
QUIT;

DATA valid_lift_score;
    SET sumout_by_score ;

    cum_n+count;       
    cum_event + asum;
    cum_good +  bsum;
    decile_pct                 = round((count/&mc_cnt),.0001);
    cum_decile_pct             = round((cum_n/&mc_cnt),.0001);

    decile_asum_count_rate     = round((asum/count),.0001);
    decile_asum_tot_event_rate = round((asum/&mc_event),.0001);
    cum_event_cum_count_rate   = round((cum_event/cum_n),.0001);
    cum_event_tot_event_rate   = round((cum_event/&mc_event),.0001);

    decile_good_count_rate     = round((bsum/count),.0001);;
    decile_good_tot_event_rate = round((bsum/&mc_good),.0001);
    cum_good_cum_count_rate    = round((cum_good/&mc_cnt),.0001);
    cum_good_tot_event_rate    = round((cum_good/&mc_good),.0001);
    cum_lift                   = round((cum_event_tot_event_rate/cum_decile_pct),.01);

    FORMAT decile_pct cum_decile_pct decile_asum_count_rate decile_asum_tot_event_rate cum_event_cum_count_rate cum_event_tot_event_rate 
           decile_good_count_rate decile_good_tot_event_rate cum_good_cum_count_rate cum_good_tot_event_rate percent10.2; 
    LABEL cum_n = '累计总客户数' cum_event = '累计坏客户数' cum_good = '累积好客户数'
          decile_pct='本组内客户数占总体比例' cum_decile_pct = '累积客户数占总体比例' 
          decile_asum_count_rate='本组内坏客户数占本组比例'  decile_asum_tot_event_rate = '本组内坏客户占总坏客户数比' 
          cum_event_cum_count_rate = '累积坏客户占总客户数比' cum_event_tot_event_rate='累积坏客户数占总坏客户数比例' 
          decile_good_count_rate='本组内好客户数占本组比例'  decile_good_tot_event_rate = '本组内好客户占总好客户数比' 
          cum_good_cum_count_rate = '累积好客户占总客户数比' cum_good_tot_event_rate='累积好客户数占总好客户数比例' 
          cum_good_tot_event_rate = '累积好客户数占总好客户数比例';
RUN;

