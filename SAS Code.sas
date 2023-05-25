FILENAME REFFILE '/home/u63222851/sasuser.v94/Netflix.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=work.project;
	GETNAMES=YES;
RUN;
data Project_new; set Project;
avgi=mean(of d10_1-d10_9);
mini=min(of d10_1-d10_9);
maxi=max(of d10_1-d10_9);
array p1 d10_1-d10_9;
array p2 new_1-new_9;
do over p2;
if p1>avgi then p2=(p1-avgi)/(maxi-avgi);
if p1<avgi then p2=(p1-avgi)/(avgi-mini);
if p1=avgi then p2=0;
if p1=. then p2=0;
end;
ods graphics on;
proc princomp data=Project_new 
              out=coord_new        /* only needed to demonstate corr(PC, orig vars) */
              plots=(scree profile pattern score);
   var new_1-new_9;  /* or use _NUMERIC_ */
   ID id;                       /* use blank ID to avoid labeling by obs number */
   ods output Eigenvectors=EV;  /* to create loadings plot, output this table */
run;

data project_2Dim_plot;
     set project_new (keep=new_1-new_9);
run;

proc corr data=coord_new noprob nosimple;
   var project_2Dim_plot;
   with Prin1-Prin4;
run; 

proc princomp data=project_2Dim_plot n=2
              plots=(Matrix PatternProfile);
run;
title "Score Plot";
title2 "Observations Projected onto PC1 and PC2";
proc sgplot data=coord_new aspect=1;
   scatter x=Prin1 y=Prin2 / group=species;
   xaxis grid label="Component 1 (18.86%)";
   yaxis grid label="Component 2 (15.12%)";
run;
title "Loadings Plot";
title2 "Variables Projected onto PC1 and PC2";
proc sgplot data=EV aspect=1;
   vector x=Prin1 y=Prin2 / datalabel=Variable;
   xaxis grid label="Component 1 (18.86%)";
   yaxis grid label="Component 2 (15.12%)";
run;

proc cluster data=coord_new method=ward outtree=tree_new;
var prin1-prin4;
id id;
run;

proc tree; run;

proc tree data=tree_new noprint nclusters=5 out=cluster_new;
id id;
run;

proc sort data=project_new; by id; run;
proc sort data=cluster_new; by id; run;
data project_new_1; merge project_new cluster_new;
by id;
run;

proc freq data=project_new_1;
table sex*cluster / expected chisq;
run;

proc freq data=project_new_1;
table age*cluster / expected chisq;
run;

proc freq data=project_new_1;
table education*cluster / expected chisq;
run;

proc freq data=project_new_1;
table relationship*cluster / expected chisq;
run;

proc freq data=project_new_1;
table frequency*cluster / expected chisq;
run;

proc freq data=project_new_1;
table origins*cluster / expected chisq;
run;

proc freq data=project_new_1;
table area_of_study_business*cluster / expected chisq;
run;

proc freq data=project_new_1;
table movies_series*cluster / expected chisq;
run;

proc freq data=project_new_1;
table number_of_seasons*cluster / expected chisq;
run;

proc freq data=project_new_1;
table episode_lenght*cluster / expected chisq;
run;

proc freq data=project_new_1;
table category*cluster / expected chisq;
run;

proc freq data=project_new_1;
table for_how_long*cluster / expected chisq;
run;

proc freq data=project_new_1;
table number_of_platforms*cluster / expected chisq;
run;

proc freq data=project_new_1;
table money_spent*cluster / expected chisq;
run;

data project_new_2; set project_new_1;
cluster4=.;
if cluster=4 then cluster4=1;
else cluster4=2;
run;

proc freq data=project_new_2;
table sex*cluster4 / expected chisq;
run;

proc freq data=project_new_2;
table age*cluster4 / expected chisq;
run;

proc freq data=project_new_2;
table education*cluster4 / expected chisq;
run;

proc freq data=project_new_2;
table relationship*cluster4 / expected chisq;
run;

proc freq data=project_new_2;
table frequency*cluster4 / expected chisq;
run;

proc freq data=project_new_2;
table origins*cluster4 / expected chisq;
run;

proc freq data=project_new_2;
table area_of_study_business*cluster4 / expected chisq;
run;

proc freq data=project_new_2;
table movies_series*cluster4 / expected chisq;
run;

proc freq data=project_new_2;
table number_of_seasons*cluster4 / expected chisq;
run;

proc freq data=project_new_2;
table episode_lenght*cluster4 / expected chisq;
run;

proc freq data=project_new_2;
table category*cluster4 / expected chisq;
run;

proc freq data=project_new_2;
table for_how_long*cluster4 / expected chisq;
run;

proc freq data=project_new_2;
table number_of_platforms*cluster4 / expected chisq;
run;

proc freq data=project_new_2;
table money_spent*cluster4 / expected chisq;
run;

data project_new_fake; set project_new_1;
cluster=6;
run;

data project_new_app; set project_new_2 project_new_fake;
run;

%macro do_k_cluster;
%do k=1 %to 6;
proc ttest data=project_new_app;
where cluster=&k or cluster=6;
class cluster;
var new:;
ods output ttests=cl_ttest_&k (where=( method='Satterthwaite') 
rename=(tvalue=tvalue_&k) rename=(probt=prob_&k));
run;
%end;
%mend do_k_cluster;
%do_k_cluster;