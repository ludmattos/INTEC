libname rais "\\sbsb3\Usuarios\Bruno Cesar Araújo\rais666";
libname atv "C:\Users\b5326589\Desktop\atv_rais";
libname bndes "\\sbsb2\DIEST\Microdados Estatistica\BNDES";

/*criação da rais painel*/
data atv.raispainel (compress=yes);
	set rais.raisempresa2004(in=a) rais.raisempresa2005(in=b) 
		rais.raisempresa2006(in=c) rais.raisempresa2007(in=d) 
		rais.raisempresa2008(in=e) rais.raisempresa2009(in=f) 
		rais.raisempresa2010(in=g) rais.raisempresa2011(in=h) 
		rais.raisempresa2012(in=i) rais.raisempresa2013(in=j) 
		rais.raisempresa2014(in=k) rais.raisempresa2015(in=l);
	    cnae20_3d=substr(cnae20,1,3);

	if a then
		ano=2004;
	if b then
		ano=2005;
	if c then
		ano=2006;
	if d then
		ano=2007;
	if e then
		ano=2008;
	if f then
		ano=2009;
	if g then
		ano=2010;
	if h then
		ano=2011;
	if i then
		ano=2012;
	if j then
		ano=2013;
	if k then
		ano=2014;
	if l then
		ano=2015;

	/*Fitro indústria*/
	cnae2=substr(cnae20,1,2);

	if "05"<=substr(cnae20,1,2)<="33";
	if "05"<=cnae2 <="09" then
		set_bndes="IND. EXTRATIVA";
	else if "10"<=cnae2 <="33" then
		set_bndes="TRANSFORMAÇÃO";
	else
		delete;

	/* Variável regiao*/
	regiao=substr(compress(uf),1,1);
run;

/*criação variáveis categóricas de intensidade tecnológica: INTEC_OCDE. INTEC_CEPAL. INTEC_PAVIT. utilizando tradutores CNAE2.0 x Classe de Tecnologia.*/
proc sort data=atv.raispainel presorted;
	by cnae20_3d;
run;

proc sort data=atv.clas_ocde_cepal_pavitt_cnae20 presorted;
	by cnae20_3d;
run;

data atv.rais_intec;
	merge atv.raispainel atv.clas_ocde_cepal_pavitt_cnae20;
	by cnae20_3d;
run;

proc format ;
	value cepalf 	1="Recursos Naturais" 
					2="Trabalho"
					3="Engenharia";
	value pavittf   1="Dominado por fornecedores" 
					2="Intensivo em escala" 
					3="Fornecedores especializados" 
					4="Baseados em ciência";
	value ocdef     1="Baixa" 
					2="Média-Baixa" 
					3="Média-Alta" 
					4="Alta" 
					.="outros";
	value $regf     "1"="Norte" 
					"2"="Nordeste" 
					"3"="Sudeste" 
					"4"="Sul" 
					"5"="Centro-Oeste";
run;

proc freq data=atv.rais_intec;
	table estrato_ocde;
	format estrato_ocde ocdef.;
run;

/*format estrato_cepal cepalf.;*/
/*format estrato_pavitt pavittf.;*/
/*format estrato_ocde ocdef.;*/

/*******BNDES*******/
proc sort data=atv.rais_intec presorted;
	by empresa ano;
run;

proc sort data=bndes.bndespainel presorted;
	by empresa ano;
run;

data atv.raisbndes_teste;
	merge bndes.bndespainel(in=a) atv.rais_intec;
	by empresa ano;
	if a;
  /*if contratacao ne '.' then bndes=1; else bndes=0;*/
run;

/*dúvida:manter ou não as empresas que não pegaram o bndes*/
proc freq data=atv.raisbndes_teste;
	table estrato_ocde;
	format estrato_ocde ocdef.;
run;

/*macro cria colunas com ano*/
%macro anos;
	%do ano=2004 %to 2015;
		data ano&ano;
			set atv.raisbndes_teste (where=(ano=&ano));
			msal&ano=msal;
			contrat&ano=contratacao;
		run;
	%end;
%mend;
%anos;

/*duvida: merge ou set?*/
data atv.raisbndes(keep=empresa msal2004-msal2015 contrat2004-contrat2015 estrato_ocde estrato_cepal estrato_Pavitt cnae20_3d msal contratacao
    rename=estrato_ocde=ocde);
	retain empresa cnae20_3d ocde estrato_cepal estrato_Pavitt msal2004-msal2015 contrat2002-contrat2015;
	set ano2004-ano2015;
run;

/*data para o cálculo do inventário*/
data atv.cross(keep=empresa msal2004-msal2015 contrat2004-contrat2015 estrato_ocde estrato_cepal estrato_Pavitt cnae20_3d );
	retain empresa cnae20_3d estrato_ocde estrato_cepal estrato_Pavitt msal2004-msal2015 contrat2002-contrat2015;
	merge ano2004-ano2015;
	by empresa;
run;

/*******Deflação das variaveis*********/
data deflator;
	input d2004 d2005 d2006 d2007 d2008 d2009 d2010 d2011 d2012 d2013 d2014 d2015;
	datalines;
1.860666329	1.755917365	1.726140358	1.64266526	1.476794877	1.450805473	1.374160711	1.266253323	1.194824362	1.126321222	1.069010409	1
;
run;

/*jeito alan*/
proc sql ;
	create table d_raisbndes as 
    select b.*, a.* 
    from atv.raisbndes a, deflator b;
quit;

data atv.d_raisbndes;
	set d_raisbndes;
	array msaldef {2004:2015};
	array contratdef {2004:2015};
	array msal {2004:2015} msal2004-msal2015;
	array contrat {2004:2015} contrat2004-contrat2015;
	array d {2004:2015} d2004-d2015;

	do ano=2004 to 2015;
		msaldef[ano]=msal[ano]*d[ano];
		contratdef[ano]=contrat[ano]*d[ano];
	end;
	rename msaldef1 - msaldef12 = msal2004 - msal2015;
	rename contratdef1 - contratdef12 = contrat2004 - contrat2015 ;
    DROP ano d2004-d2015 msal2004-msal2015 contrat2004-contrat2015;
run;


/*******criar tabelas descritivas******/
/*tabela valor de contrataçao por intensidade tecnologica*/
%macro burrice;
	%do ano=2004 %to 2015;
		proc sql ;
			create table contrat&ano as 
			select ocde, sum(contrat&ano) as c&ano label="&ano"
            from atv.d_raisbndes 
			group by ocde 
			order by ocde;
		quit;
	%end;
%mend;
%burrice;

data atv.contratacao;
	merge contrat2004-contrat2015;
	by ocde;
	format ocde ocdef. c2004 - c2015 COMMAX20.2 ;
run;

proc export outfile="C:\Users\b5326589\Desktop\atv_rais\tabelas.XLS" dbms=xls REPLACE  data= ATV.contratacao;
SHEET='CONTRATAÇÃO';
RUN;

/*tabela massa salarial por intensidade tecnologica*/
%macro burrice;
	%do ano=2004 %to 2015;
		proc sql ;
			create table msal&ano as 
			select ocde, sum(msal&ano) as c&ano label="&ano"
            from atv.d_raisbndes 
			group by ocde 
			order by ocde;
		quit;
	%end;
%mend;
%burrice;

data atv.msal;
	merge msal2004-msal2015;
	by ocde;
	format ocde ocdef. c2004 - c2015 COMMAX20.2 ;
run;

proc export outfile="C:\Users\b5326589\Desktop\atv_rais\tabelas.XLS" dbms=xls REPLACE  data= atv.msal;
SHEET='Massa salarial';
RUN;

/**************graficos exploratórios*****************/
PROC TRANSPOSE DATA = ATV.CONTRATACAO OUT=TESTE;
BY ocde;
RUN;

DATA TESTE; SET TESTE;
CONTRATACAO=COL1/100000000;
IF ocde=. THEN DELETE;
if contratacao=. then delete;
LABEL _LABEL_=ANO;
RUN;

TITLE  'VALOR DE CONTRATAÇÃO POR INTENSIDADE TECOLOGICA';
axis1 label=none value=none;                                                                                                                                                                                                         
axis2 label=(angle=90 'Percent');                                                                                                       
proc gchart data=testE;                                                                                                                  
   vbar _LABEL_ / discrete subgroup=ocde                                                                                           
                 group=_LABEL_ g100 nozero                                                                                               
                 freq=CONTRATACAO type=percent                                                                                                
                 inside=percent width=40        
				 gaxis=axis1 raxis=axis2                                                                                       
                ;                                                                                                        
run;                                                                                                                                    
quit;                                                                                                  
 


/*GRAFICO PARA MASSA SALARIAL*/
PROC TRANSPOSE DATA = atv.MSAL OUT=TESTE2;
BY ocde;
RUN;

DATA TESTE2; SET TESTE2;
MSAL=COL1/1000000000;
IF ocde=. THEN DELETE;
IF MSAL=. THEN DELETE;
LABEL _LABEL_=ANO;
RUN;

TITLE  'MASSA SALARIAL POR INTENSIDADE TECOLOGICA' ;                                                                                  
axis1 label=none value=none;                                                                                                                                                                                                         
axis2 label=(angle=90 'Percent');  
proc gchart data=testE2;                                                                                                                  
   vbar _LABEL_ / discrete subgroup=ocde                                                                                        
                 group=_LABEL_   g100 nozero                                                                                         
                 freq=MSAL type=percent                                                                                                
                 inside=percent width=30
				 gaxis=axis1 raxis=axis2   
                ;                                                                                                        
run;                                                                                                                                    
quit;   




/*MODELO REGRESSIVO*/
data raisbndes; set atv.raisbndes;
y=log(contratacao/msal);
lcontrat =log(contratacao);
run;

proc reg data=raisbndes ;
model y=ocde;
model y=estrato_Pavitt;
model y=estrato_cepal;
format estrato_cepal cepalf.
 estrato_pavitt pavittf.
 ocde ocdef.;
run;

proc reg data=raisbndes ;
model lcontrat=ocde;
model lcontrat=estrato_Pavitt;
model lcontrat=estrato_cepal;
format estrato_cepal cepalf.
 estrato_pavitt pavittf.
 ocde ocdef.;
run;











/*estoque*/
%macro estoq;
DATA atv.cross;SET atv.cross;
%do ano=2004 %to 2015;
%let ano_1=%eval(&ano.-1);
estoque2003=0;
delta = 0.05;
/*método do inventário perpétuo*/
estoque&ano.=sum( (1-delta)*estoque&ano_1. , contrat&ano.);
%end;
RUN;
%mend;
%estoq;







