
/****************  常用全程语句  ****************/
OPTIONS           *规定系统选项;
    nonumber      *输出不显示页号;
    nodate        *不在每页显示运行日期和时间;
    linesize=64   *输出每行最多64个字符;
    pagesize=60   *输出每页最多60行 ;
;

* TITLE打印SAS输出文件和其他SAS输出的标题，每个TITLE语句规定一条标题行，最多可规定10个标题行;
TITLE<n> <text|text>;    * n紧跟在TITLE后面表示标题的级别，text定义标题内容;
* 同时列出三级标题;
TITLE1 "here is title1";
TITLE2 "here is title2";
TITLE3 "here is title3";

TITLE '95级1班成绩表';  *指定结果的报告标题;    
TITLE;                  *取消所有标题，指定结果的报告标题为空（默认是The SAS System）;     

* FOOTNODE规定在每页底部输出一些脚注行，最多生成10个脚注行，用法类似TITLE;
FOOTNOTE '95级1班成绩表'; *为输出加注脚;


* X：执行主机操作系统命令;
X "del d:\aaa.txt";   * DOS命令删除文件;


* FILENAME：用一个SAS文件标记关联外部文件或输出设备;
FILENAME fileref 
FILENAME fileref CLEAR |_ALL_ CLEAR;  * 清除关联;
FILENAME fileref LIST |_ALL_ LIST;    * 列出外部文件属性;

* 发送电子邮件;
OPTIONS 
  EMAILAUTHPROTOCOL = login                 
  EMAILSYS          = smtp 
  EMAILPORT         = 25 
  EMAILHOST         = "smtp.qiye.163.com" 
  EMAILID           = "zhangyan@xxxx.com"
  EMAILPW           = "xxxxxxxx";
FILENAME mymail EMAIL "zhangyan@xxxx.com" subject="SAS OUTPUT SYSTEM" ENCODING=gb2312;
DATA _null_;
  FILE mymail TO=("zhangyan@xxxx.com") ATTACH=("D:\utf.txt");  
  PUT "!EM_TO!" "zy_79@sina.com";                          *指定邮件发送的地址;
  PUT "!EM_SUBJECT! The output result by SAS";             *指定邮件的主题;
  PUT "!EM_ATTACH!" "D:\utf.txt";                          *指定邮件所添加的附件;
  PUT "尊敬的 XX(先生/女士)：";                            *把邮件接收者的姓名添加到邮件中;
  PUT "    您好!程序已经运行成功，现在把结果给您发过去，请查看附件。";
  RETURN;
RUN;

FILENAME fileref URL 'http://www.baidu.com';    * 访问URL，抓取网页源码，在WEB文本挖掘中常用;
DATA sas;
	INFILE fileref LENGTH = len LRECL=4000;
	INPUT record $ varying4000. len;
RUN;

FILENAME fileref FTP   'external-file';    * 访问FTP;

* %INCLUDE调用SAS程序脚本、代码、外部文件、数据行;
%INCLUDE "d:\aaa.sas";     * 直接调用一个SAS程序，执行该语句等价于批处理脚本aaa.sas中的程序;

FILENAME sasf "d:\aaa.sas";  * 通过文件方式调用sas脚本，等效于上述;
%INCLUDE sasf;

FILENAME sasf "d:\";  * 一次调入多个sas脚本;
%INCLUDE sasf(aaa.sas,bbb.sas);

FILENAME fb "d:\";    * 导入建模打分文件;
DATA score;
  SET fitness;
  %INCLUDE fb;
RUN;



