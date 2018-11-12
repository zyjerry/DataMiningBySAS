* 案例数据
DATA aaa ;
    INPUT year high low decade @@;
    CARDS;
1956  521.05  462.35 50 1957  520.77  419.79 50
1958  583.65  436.89 50 1959  679.36  574.46 50
1960  685.47  568.05 60 1961  734.91  610.25 60
1962  726.01  535.76 60 1963  767.21  646.79 60
1964  891.71  768.08 60 1965  969.26  840.59 60
1966  995.15  744.32 60 1967  943.08  786.41 60
1968  985.21  825.13 60 1969  968.85  769.93 60
1970  842.00  631.16 70 1971  950.82  797.97 70
1972 1036.27  889.15 70 1973 1051.70  788.31 70
1974  891.66  577.60 70 1975  881.81  632.04 70
1976 1014.79  858.71 70 1977  999.75  800.85 70
1978  907.74  742.12 70 1979  897.61  796.67 70
1980 1000.17  759.13 80 1981 1024.05  824.01 80
1982 1070.55  776.92 80 1983 1287.20 1027.04 80
1984 1286.64 1086.57 80 1985 1553.10 1184.96 80
1986 1955.57 1502.29 80 1987 2722.42 1738.74 80
1988 2183.50 1879.14 80 1989 2791.41 2144.64 80
1990 2999.75 2365.10 90 1991 3168.83 2470.30 90
1992 3413.21 3136.58 90 1993 3794.33 3241.95 90
1994 3978.36 3593.35 90 1995 5216.47 3832.08 90
;
RUN;

DATA bbb;
    LENGTH dept $7 site $8;
    INPUT dept site quarter sales;
    DATALINES;
Parts Sydney  1 7043.97
Parts Atlanta 1 8225.26
Parts Paris   1 5543.97
Tools Sydney  4 1775.74
Tools Atlanta 4 3424.19
Tools Paris   4 6914.25
;
RUN;


* BLOCK（方块图）、HBAR（水平条图）、HBAR3D（3d水平条图）、VBAR（垂直条图）、VBAR3D（3d垂直条图）、PIE（饼图）、PIE3D（3d饼图）、DOUNT（环形图）、STAR(星形图);
PROC GCHART DATA = aaa;
    VBAR year                  /*由于year是数值变量，所以该结果是基于year的分箱，默认统计频数*/ 
        / TYPE=SUM 
          SPACE=4    /*TYPE指定纵坐标的指标，可以指定以下任意值：freq（默认），cfreq（cumulativefrequency），percent pct（percentage），cpercent cpct（cumulative percentage）*/ 
          midpoints=(1959 to 1994 (by 3)) /*用来指定分段的组中值。对于数值型变量，即可以指定具体的值，也指定区间（指定区间的增量increment）*/
         ;
RUN;

PROC GCHART DATA = bbb;
    VBAR site;  /*由于site是名义变量，所以site有几种值，横坐标就是几个，默认统计频数*/ 
RUN;


* 散点图
PROC GPLOT DATA=aaa;
   PLOT high*year =Region; / haxis=1955 to 1995 by 5/*横坐标刻度*/
                    vaxis=0 TO 6000 BY 1000/*纵坐标刻度*/
                    hminor=3/*横坐标刻度之间标记数量为3*/
                    vminor=1/*纵坐标刻度之间标记数量为1*/
                    vref=1000 3000 5000 /*参考线在纵坐标上的位置*/
                    lvref=2/*格式：2表示为虚线*/
                    caxis=blue
                    ctext=red
                    grid;
  WHERE Region IN("United States", "EasternEurope");
RUN;

散点图：主要对symbol语句的理解
格式为：SYMBOLn options;/*n可以从1到99*/
复制代码
option的选项有：
1. VALUE==symbol | V=symbol
复制代码
V可以选 value.jpg 
另外还有选项：
2. I=interpolation
复制代码
可以选折线：JOIN、光滑曲线：SPLINE
此外还有
3.color= 和width=表示连线的颜色跟粗细

关于画图暂时学到这里，还有一些三维图的学习以后再细看

如果要对网格进行更精细地设置，则要用到AUTOHREF和AUTOVREF选项。AUTOHREF中，LHREF设置水平线的线类型，CHREF设置水平线的线颜色；AUTOVREF中，LVREF设置垂直线的线类型，CVREF设置垂直线的线颜色。

还可以用VAXIS和HAXIS分别设置纵轴和横轴的刻度。注意：如果某个数据超过了你指定的这个刻度，那么这个数据将不会被输出，因此在用这两个选项时要非常小心。




* 箱形图/盒形图：由一组数据的最大值、最小值、中位数、平均值、两个四分位数6个特征值绘制而成,反映原始数据分布的图形，中间菱形的点是平均值，中间的线是中位数.
PROC BOXPLOT DATA=aaa; 
	PLOT high * decade; /*high是纵坐标的指标值，decade是横坐标的分组*/
	TITLE  '盒形图';
RUN;

*（9.2及以上版本支持）
PROC SGPLOT DATA=origin_data; 
	VBOX x;
RUN;



7. 下面介绍一些有关Graph相关过程的全局(global)设置

title1 c=darkblue h=2.5 f=swissb "SAS/Graph "

c=darkred h=3.0 f=swissbi "GPLOT Example";

axis1

label=(c=darkorange h=1.5 f=zapfbi

j=r "Total Returns")

offset=(0.2 in )

order=(0 to 15000 by 5000)

value=(c=darkorange f=swissl );

axis2

label=(c=darkgreen h=1.5 f=zapfbi)

order=(0 to 500000 by 50000)

value=(f=swissl c=darkgreen);

symbol1 c=red h=2 v=# ;

symbol2 c=blue h=3 v=diamond;

PROC GPLOT DATA=sashelp.shoes;
    WHERE Region IN("United States","EasternEurope");
    PLOT Returns * Sales=Region /
         vaxis=axis1 haxis=axis2
         autohref lhref=2 chref=lime
         autovref lvref=5 cvref=pink
         caxis=blue ctext=red ;
RUN;

ODS GRAPHICS ON; 
ODS GRAPHICS OFF; 