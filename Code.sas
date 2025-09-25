*** Esame MSB ***; 

** Lettura dataset e data preprocessing **;

*** Creo una libname ***;
LIBNAME Esame 'C:\Users\amade\Desktop\Esame MSB\Esame';

*** Rielaboro il dataset ***;
DATA Esame.Psa2;
	SET Esame.Psa;
	Eta=year(datini)-year(datnas);
	Anno=year(datini);
	IF month(datini) >= 01 and month(datini)<04 THEN Stagione='  Inverno';
	IF month(datini) >= 04 and month(datini)<07 THEN Stagione='Primavera';
	IF month(datini) >= 07 and month(datini)<10 THEN Stagione='Estate';
	IF month(datini) >= 10 and month(datini)<13 THEN Stagione='Autunno';
	Psa1=psa__1+0.1; Psa2=psa__2+0.1; Differenza=psa__2-psa__1;
	DROP psa__1 psa__2;
	LABEL Psa1='PSA Basale';
	LABEL Psa2='PSA Finale';
	LABEL tratta='Trattamento';
RUN;
** Ho aggiunto 0.1 per problemi riguardo a valori uguali a 0; **

*** Analisi descrittiva PSA ***;

*Distribuzione PSA;
PROC UNIVARIATE DATA=Esame.Psa2;
	VAR Psa1;
	HISTOGRAM Psa1 / NORMAL(COLOR=yellow W=3 PERCENTS=10 20 30 40 50 60 70 80 90 MIDPERCENTS)
	CFILL = blue CFRAME = ligr NAME='PSA INIZIALE'; 
	QQPLOT Psa1 / NORMAL (SIGMA=EST MU=EST);
	OUTPUT OUT=SP1 MEAN=MA VAR=VAR CV=CV MEDIAN=P50;
RUN;

PROC UNIVARIATE DATA=Esame.Psa2;
	VAR Psa2;
	HISTOGRAM Psa2 / NORMAL(COLOR=yellow W=3 PERCENTS=10 20 30 40 50 60 70 80 90 MIDPERCENTS)
	CFILL = blue CFRAME = ligr NAME='PSA FINALE';
	QQPLOT Psa2 / NORMAL (SIGMA=EST MU=EST);
	OUTPUT OUT=SP2 MEAN=MA VAR=VAR CV=CV MEDIAN=P50;
RUN;
** Poiche Psa1 e Psa2 non hanno una distribuzione normale si applica il logaritmo **;

*Differenza;
PROC UNIVARIATE DATA=Esame.Psa2;
	VAR Differenza;
RUN;

PROC SORT DATA=Esame.Psa2;
	BY tratta;
RUN;

PROC BOXPLOT DATA=Esame.Psa2;
	PLOT Differenza*tratta;
	INSET MIN MEAN MAX STDDEV /
	POS = TM; INSETGROUP MEAN Q2;
RUN;

*Logaritmo PSA;
DATA Esame.Psa3;
	SET Esame.Psa2;
	LPSA1=log(Psa1); LPSA2=log(Psa2);
	DROP Psa1 Psa2;
	LABEL LPSA1='Logaritmo PSA Basale';
	LABEL LPSA2='Logaritmo PSA Finale';
RUN;

*Distribuzione LOG(PSA);
PROC UNIVARIATE DATA=Esame.Psa3;
	VAR LPSA1;
	HISTOGRAM LPSA1 / NORMAL(COLOR=yellow W=3 PERCENTS=10 20 30 40 50 60 70 80 90 MIDPERCENTS)
	CFILL = blue CFRAME = ligr NAME='LPSA INIZIALE';
	QQPLOT LPSA1 / NORMAL (SIGMA=EST MU=EST);
	OUTPUT OUT=SLP1 MEAN=LMA VAR=LVAR CV=LCV MEDIAN=LP50;
RUN;

PROC UNIVARIATE DATA=Esame.Psa3;
	VAR LPSA2;
	HISTOGRAM LPSA2 / NORMAL(COLOR=yellow W=3 PERCENTS=10 20 30 40 50 60 70 80 90 MIDPERCENTS)
	CFILL = blue CFRAME = ligr NAME='LPSA FINALE';
	QQPLOT LPSA2 / NORMAL (SIGMA=EST MU=EST);
	OUTPUT OUT=SLP2 MEAN=LMA VAR=LVAR CV=LCV MEDIAN=LP50;
RUN;
** Il logaritmo del Psa sembra presentare una distribuzione normale **;

*** Verifico condizioni di lognormalita tramite le statistiche ***;

DATA SLP1; 
	SET SLP1;
	MA=exp(LMA+(LVAR/2));
	VAR=(exp(LVAR)-1)*(exp(2*LMA+LVAR));
	P50=exp(LMA);
	CV=sqrt(exp(LVAR)-1)*100;
	DROP LMA LVAR LCV LP50;
RUN;

DATA SLP2; 
	SET SLP2;
	MA=exp(LMA+(LVAR/2));
	VAR=(exp(LVAR)-1)*(exp(2*LMA+LVAR));
	P50=exp(LMA);
	CV=sqrt(exp(LVAR)-1)*100;
	DROP LMA LVAR LCV LP50;
RUN;

DATA CONFRONTO1;
	SET SP1 SLP1;
RUN;

DATA CONFRONTO2;
	SET SP2 SLP2;
RUN;

PROC TRANSPOSE DATA=CONFRONTO1 
	OUT=CONFRONTO1; 
RUN;

PROC TRANSPOSE DATA=CONFRONTO2
	OUT=CONFRONTO2; 
RUN;

DATA CONFRONTO1;
	SET CONFRONTO1(RENAME=(COL1=PSA COL2=LPSA _NAME_=STATISTICA));
	RAPPORTO=(PSA/LPSA);
	PSA=ROUND(PSA, .001);
	LPSA=ROUND(LPSA, .001);
	RAPPORTO=ROUND(RAPPORTO, .001);
	LABEL STATISTICA='STATISTICA'; 
	DROP _LABEL_;
RUN;

DATA CONFRONTO2;
	SET CONFRONTO2(RENAME=(COL1=PSA COL2=LPSA _NAME_=STATISTICA));
	RAPPORTO=(PSA/LPSA);
	PSA=ROUND(PSA, .001);
	LPSA=ROUND(LPSA, .001);
	RAPPORTO=ROUND(RAPPORTO, .001);
	LABEL STATISTICA='STATISTICA'; 
	DROP _LABEL_;
RUN;


** Analisi Descrittiva su Logaritmo PSA ***;

*Anno;

* Ordino per Anno;
PROC SORT DATA=Esame.Psa3;
	BY Anno;
RUN;

** Boxplot LPSA per Anno **;
PROC BOXPLOT DATA=Esame.Psa3;
	PLOT LPSA1*Anno;
	INSET MIN MEAN MAX STDDEV /
	POS = TM; INSETGROUP MEAN Q2;
RUN;

PROC BOXPLOT DATA=Esame.Psa3;
	PLOT LPSA2*Anno;
	INSET MIN MEAN MAX STDDEV /
	POS = TM; INSETGROUP MEAN Q2;
RUN;

*Stagione;

* Ordino per Stagione;
PROC SORT DATA=Esame.Psa3;
	BY Stagione;
RUN;

** Boxplot LPSA per Stagione **;
PROC BOXPLOT DATA=Esame.Psa3;
	PLOT LPSA1*Stagione;
	INSET MIN MEAN MAX STDDEV /
	POS = TM; INSETGROUP MEAN Q2;
RUN;

PROC BOXPLOT DATA=Esame.Psa3;
	PLOT LPSA2*Stagione;
	INSET MIN MEAN MAX STDDEV /
	POS = TM; INSETGROUP MEAN Q2;
RUN;

*Trattamento;

* Ordino per trattamento;
PROC SORT DATA=Esame.Psa3;
	BY Tratta;
RUN;

** Boxplot LPSA per Trattamento **;
PROC BOXPLOT DATA=Esame.Psa3;
	PLOT LPSA1*Tratta;
	INSET MIN MEAN MAX STDDEV /
	POS = TM; INSETGROUP MEAN Q2;
RUN;

PROC BOXPLOT DATA=Esame.Psa3;
	PLOT LPSA2*Tratta;
	INSET MIN MEAN MAX STDDEV /
	POS = TM; INSETGROUP MEAN Q2;
RUN;

*Costruisco 4 fasce di eta e rinomino l'ipertrofia;
DATA Esame.Psa4;
	SET Esame.Psa3;
	IF Eta <= 51 THEN FasciaEta = "  Minore di 52";
	IF Eta >= 52 and Eta < 57 THEN FasciaEta = "Tra 52 e 56";
	IF Eta >= 57 and Eta < 60 THEN FasciaEta = "Tra 57 e 60";
	IF Eta >= 60 THEN FasciaEta = "Maggiore di 60";
	IF Ipeben = '1' THEN Ipertrofia = "Assente";
	IF Ipeben = '2' THEN Ipertrofia = "Lieve";
	IF Ipeben = '3' THEN Ipertrofia = "Severa";
	LABEL FasciaEta = 'Fascia di et�';
	LABEL Ipertrofia = 'Ipertrofia Prostatica';
	DROP Ipeben;
RUN;

*Ipertrofia Prostatica;

*Ordino il dataset per eta;
PROC SORT DATA=Esame.Psa4;
	BY Ipertrofia;
RUN;

** Boxplot LPSA per Ipertrofia Prostatica **;
PROC BOXPLOT DATA=Esame.Psa4;
	PLOT LPSA1*Ipertrofia;
	INSET MIN MEAN MAX STDDEV /
	POS = TM; INSETGROUP MEAN Q2;
RUN;

PROC BOXPLOT DATA=Esame.Psa4;
	PLOT LPSA2*Ipertrofia;
	INSET MIN MEAN MAX STDDEV /
	POS = TM; INSETGROUP MEAN Q2;
RUN;

*Eta;

*Ordino il dataset per et�;
PROC SORT DATA=Esame.Psa4;
	BY Eta;
RUN;

*Boxplot LPSA per Fasce di Eta;
PROC BOXPLOT DATA=Esame.Psa4;
	PLOT LPSA1*FasciaEta;
	INSET MIN MEAN MAX STDDEV /
	POS = TM;INSETGROUP MEAN Q2;
RUN;

PROC BOXPLOT DATA=Esame.Psa4;
	PLOT LPSA2*FasciaEta;
	INSET MIN MEAN MAX STDDEV /
	POS = TM; INSETGROUP MEAN Q2;
RUN;

* Quantitative;

*Correlazione;
PROC CORR DATA=Esame.Psa3 NOPROB;
	VAR ETA LPSA1 LPSA2;
RUN;

*** Modello di regressione multipla a errore normale ***;

*Scalo i dati;
DATA Esame.Psa5 (rename=(tratta=Trattamento));
	SET Esame.Psa3;
	Eta40=Eta-40; 
	Anno2005=Anno-2005;
	DROP Eta Anno;
RUN;

*Modello completo;
PROC GENMOD DATA=Esame.Psa5 ORDER=INTERNAL;
	CLASS  Trattamento (REF='1') Ipeben (REF='1') Stagione (REF='Inverno') Anno2005 (REF='0')/ PARAM=REF;
    MODEL  LPSA2 = LPSA1 Trattamento Ipeben Eta40 Stagione Anno2005 /LINK = ID DIST = NOR TYPE3;
RUN;

*Modello ridotto;
PROC GENMOD DATA=Esame.Psa5 ORDER=INTERNAL;
	MAKE 'ParameterEstimates' OUT=STAT1;
	CLASS  Trattamento (REF='1') Stagione (REF='Inverno') Anno2005 (REF='0')/ PARAM=REF;
    MODEL  LPSA2 = LPSA1 Trattamento Eta40 Stagione Anno2005 /LINK = ID DIST = NOR TYPE3;
    OUTPUT OUT=RESIDUI RESCHI=STDRES;
RUN;

*Coefficienti;
DATA STAT1;
     SET STAT1;
	 KEEP PARAMETER LEVEL1 BETA INF SUP EXP INF_EXP SUP_EXP;
	 IF PARAMETER='Scala' THEN DELETE;
	 BETA=ESTIMATE; INF=LowerWaldCL; SUP=UpperWaldCL;
	 EXP=EXP(BETA); INF_EXP=EXP(INF); SUP_EXP=EXP(SUP);
RUN;

PROC PRINT DATA=STAT1;
     VAR PARAMETER LEVEL1 EXP INF_EXP SUP_EXP;
RUN;

*Analisi dei residui;
PROC UNIVARIATE DATA=RESIDUI;
     VAR STDRES;
     HISTOGRAM STDRES / NORMAL(COLOR=yellow W=3 PERCENTS=10 20 30 40 50 60 70 80 90 MIDPERCENTS)
     CFILL  = blue CFRAME = ligr NAME='RESIDUI DI PEARSON';
     QQPLOT STDRES / NORMAL (SIGMA=EST MU=EST);
RUN;

*** Modello di regressione alternativo ***; 

*Creo la variabile DiffPsa che contiene la differenza tra i due livelli di Psa;
DATA Esame.Psa6;
	 SET Esame.Psa3;
	 DiffPsa=LPSA2-LPSA1;
	 Eta40=Eta-40;
	 Anno2005=Anno-2005;
	 IF tratta='1' THEN Trattamento='Non Trattati';
	 IF tratta='2' THEN Trattamento='Trattati';
	 LABEL DiffPsa='Differenza Logaritmo PSA';
	 DROP LPSA2 LPSA1 Eta Anno tratta;
RUN;

*Frequenza trattamento;
PROC FREQ DATA=Esame.Psa6;
	TABLES Trattamento / NOCUM NOPERCENT NOROW NOCOLUMN;
RUN;

*Distribuzione Differenza PSA;
PROC UNIVARIATE DATA=Esame.Psa6;
	VAR DiffPsa;
	HISTOGRAM DiffPsa / NORMAL(COLOR=yellow W=3 PERCENTS=10 20 30 40 50 60 70 80 90 MIDPERCENTS)
	CFILL = blue CFRAME = ligr NAME='DIFFERENZA PSA';
	QQPLOT DiffPsa / NORMAL (SIGMA=EST MU=EST);
RUN;

*Trattamento su differenza di LPSA;

* Ordino per trattamento;
PROC SORT DATA=Esame.Psa6;
	BY Trattamento;
RUN;

** Boxplot LPSA per Trattamento **;
PROC BOXPLOT DATA=Esame.Psa6;
	PLOT DiffPSA*Trattamento;
	INSET MIN MEAN MAX STDDEV /
	POS = TM; INSETGROUP Q2 MEAN STDDEV;
RUN;

*Modello alternativo completo;
PROC GENMOD DATA=Esame.Psa6 ORDER=INTERNAL;
	CLASS  Trattamento (REF='Non Trattati') Ipeben (REF='1') Stagione (REF='Inverno') Anno2005 (REF='0')/ PARAM=REF;
    MODEL  DiffPsa = Trattamento Ipeben Eta40 Stagione Anno2005 /LINK = ID DIST = NOR TYPE3;
RUN;

*Modello alternativo ridotto;
PROC GENMOD DATA=Esame.Psa6 ORDER=INTERNAL;
	MAKE 'ParameterEstimates' OUT=STAT2;
	CLASS  Trattamento (REF='Non Trattati') Stagione (REF='Inverno') Anno2005 (REF='0')/ PARAM=REF;
    MODEL  DiffPsa = Trattamento Stagione Anno2005 /LINK = ID DIST = NOR TYPE3;
    OUTPUT OUT=RESIDUI2 RESCHI=STDRES2;
RUN;

*Coefficienti;
DATA STAT2;
	SET STAT2;
	KEEP PARAMETER LEVEL1 BETA INF SUP EXP INF_EXP SUP_EXP;
	IF PARAMETER='Scala' THEN DELETE;
	BETA=ESTIMATE; INF=LowerWaldCL; SUP=UpperWaldCL;
	EXP=EXP(BETA); INF_EXP=EXP(INF); SUP_EXP=EXP(SUP);
RUN;

PROC PRINT DATA=STAT2;
    VAR PARAMETER LEVEL1 EXP INF_EXP SUP_EXP;
RUN;

*Analisi dei residui;
PROC UNIVARIATE DATA=RESIDUI2;
	VAR STDRES2;
    HISTOGRAM STDRES2 / NORMAL(COLOR=yellow W=3 PERCENTS=10 20 30 40 50 60 70 80 90 MIDPERCENTS)
    CFILL  = blue CFRAME = ligr NAME='RESIDUI DI PEARSON';
    QQPLOT STDRES2    / NORMAL (SIGMA=EST MU=EST);
RUN;

*Per stimare l'incremento medio in PSA2 per eta elevo all'esponenziale il beta relativo all'eta;

*** Analizzo i confondimenti ***;

*Modello trattamento;
PROC GENMOD DATA=Esame.Psa5 ORDER=INTERNAL;
	MAKE 'ParameterEstimates' OUT=STATT;
	CLASS  Trattamento (REF='1') / PARAM=REF;
    MODEL  LPSA2 = Trattamento /LINK = ID DIST = NOR TYPE3;
    OUTPUT OUT=RESIDUIT RESCHI=STDREST;
RUN;

*Coefficienti;
DATA STATT;
     SET STATT;
	 KEEP PARAMETER BETA INF SUP EXP INF_EXP SUP_EXP;
	 IF PARAMETER='Scala' THEN DELETE;
	 BETA=ESTIMATE; INF=LowerWaldCL; SUP=UpperWaldCL;
	 EXP=EXP(BETA); INF_EXP=EXP(INF); SUP_EXP=EXP(SUP);
RUN;

DATA STATT;
	SET STATT;
	LENGTH Modello $25;
	IF Parameter^='Trattamento' THEN DELETE;
	Devianza=1.0015;
	AIC=3354.7818;
	Modello='Singolo';
	DROP Parameter;
RUN;

PROC PRINT DATA=STATT;
     VAR MODELLO DEVIANZA AIC EXP INF_EXP SUP_EXP;
RUN;

*Modello quantitative;
PROC GENMOD DATA=Esame.Psa5 ORDER=INTERNAL;
	MAKE 'ParameterEstimates' OUT=STAT3;
	CLASS  Trattamento (REF='1') / PARAM=REF;
    MODEL  LPSA2 = Trattamento LPSA1 Eta40 /LINK = ID DIST = NOR TYPE3;
    OUTPUT OUT=RESIDUI3 RESCHI=STDRES3;
RUN;

*Coefficienti;
DATA STAT3;
    SET STAT3;
	KEEP PARAMETER BETA INF SUP EXP INF_EXP SUP_EXP;
	IF PARAMETER='Scala' THEN DELETE;
	BETA=ESTIMATE; INF=LowerWaldCL; SUP=UpperWaldCL;
	EXP=EXP(BETA); INF_EXP=EXP(INF); SUP_EXP=EXP(SUP);
RUN;

DATA STAT3;
	SET STAT3;
	LENGTH Modello $25;
	IF Parameter^='Trattamento' THEN DELETE;
	Devianza=1.0031;
	AIC=1921.8470;
	Modello='Quantitative';
	DROP Parameter;
RUN;

PROC PRINT DATA=STAT3;
    VAR MODELLO DEVIANZA AIC EXP INF_EXP SUP_EXP;
RUN;

*Modello qualitative;
PROC GENMOD DATA=Esame.Psa5 ORDER=INTERNAL;
	MAKE 'ParameterEstimates' OUT=STAT4;
	CLASS  Trattamento (REF='1') Stagione (REF='Inverno') Anno2005(REF='0') / PARAM=REF;
    MODEL  LPSA2 = Trattamento Stagione Anno2005 /LINK = ID DIST = NOR TYPE3;
    OUTPUT OUT=RESIDUI4 RESCHI=STDRES4;
RUN;

*Coefficienti;
DATA STAT4;
    SET STAT4;
	KEEP PARAMETER BETA INF SUP EXP INF_EXP SUP_EXP;
	IF PARAMETER='Scala' THEN DELETE;
	BETA=ESTIMATE; INF=LowerWaldCL; SUP=UpperWaldCL;
	EXP=EXP(BETA); INF_EXP=EXP(INF); SUP_EXP=EXP(SUP);
RUN;

DATA STAT4;
	SET STAT4;
	LENGTH Modello $25;
	IF Parameter^='Trattamento' THEN DELETE;
	Devianza=1.0054;
	AIC=3352.3579;
	Modello='Qualitative';
	DROP Parameter;
RUN;

PROC PRINT DATA=STAT4;
     VAR MODELLO DEVIANZA AIC EXP INF_EXP SUP_EXP;
RUN;

*Modello qualitative con LPSA;
PROC GENMOD DATA=Esame.Psa5 ORDER=INTERNAL;
	MAKE 'ParameterEstimates' OUT=STAT5;
	CLASS  Trattamento (REF='1') Stagione (REF='Inverno') Anno2005(REF='0') / PARAM=REF;
    MODEL  LPSA2 =  Trattamento LPSA1 Stagione Anno2005 /LINK = ID DIST = NOR TYPE3;
    OUTPUT OUT=RESIDUI5 RESCHI=STDRES5;
RUN;

*Coefficienti;
DATA STAT5;
	SET STAT5;
	KEEP PARAMETER BETA INF SUP EXP INF_EXP SUP_EXP;
	IF PARAMETER='Scala' THEN DELETE;
	BETA=ESTIMATE; INF=LowerWaldCL; SUP=UpperWaldCL;
	EXP=EXP(BETA); INF_EXP=EXP(INF); SUP_EXP=EXP(SUP);
RUN;

DATA STAT5;
	SET STAT5;
	LENGTH Modello $25;
	IF Parameter^='Trattamento' THEN DELETE;
	Devianza=1.0061;
	AIC=1868.8543;
	Modello='Qualitative con LPSA';
	DROP Parameter;
RUN;

PROC PRINT DATA=STAT5;
     VAR MODELLO DEVIANZA AIC EXP INF_EXP SUP_EXP;
RUN;

*Modello con iterazione;
PROC GENMOD DATA=Esame.Psa5 ORDER=INTERNAL;
	MAKE 'ParameterEstimates' OUT=STAT6;
	CLASS  Trattamento (REF='1') Stagione (REF='Inverno') Anno2005 (REF='0')/ PARAM=REF;
    MODEL  LPSA2 = Trattamento LPSA1 Eta40 Stagione Anno2005 Anno2005*LPSA1 /LINK = ID DIST = NOR TYPE3;
    OUTPUT OUT=RESIDUI6 RESCHI=STDRES6;
RUN;

*Coefficienti;
DATA STAT6;
    SET STAT6;
	KEEP PARAMETER LEVEL1 BETA INF SUP EXP INF_EXP SUP_EXP;
	IF PARAMETER='Scala' THEN DELETE;
	BETA=ESTIMATE; INF=LowerWaldCL; SUP=UpperWaldCL;
	EXP=EXP(BETA); INF_EXP=EXP(INF); SUP_EXP=EXP(SUP);
RUN;

PROC PRINT DATA=STAT6;
	VAR PARAMETER LEVEL1 BETA INF SUP EXP INF_EXP SUP_EXP;
RUN;

DATA STAT6;
	SET STAT6;
	LENGTH Modello $25;
	IF Parameter^='Trattamento' THEN DELETE;
	Devianza=1.0085;
	AIC=1848.7796;
	Modello='Completo con iterazione';
	DROP Parameter LEVEL1;
RUN;

PROC PRINT DATA=STAT6;
	VAR MODELLO DEVIANZA AIC EXP INF_EXP SUP_EXP;
RUN;

*Analisi dei residui;
PROC UNIVARIATE DATA=RESIDUI6;
     VAR STDRES6;
     HISTOGRAM STDRES6 / NORMAL(COLOR=yellow W=3 PERCENTS=10 20 30 40 50 60 70 80 90 MIDPERCENTS)
     CFILL  = blue CFRAME = ligr NAME='RESIDUI DI PEARSON';
     QQPLOT STDRES6 / NORMAL (SIGMA=EST MU=EST);
RUN;

*** Confronto ***;

DATA STAT1;
	SET STAT1;
	LENGTH Modello $25;
	IF Parameter^='Trattamento' THEN DELETE;
	Devianza=1.0069;
	AIC=1853.5160;
	Modello='Completo';
	DROP Parameter;
RUN;

DATA CONFRONTO;
	SET STATT STAT4 STAT3 STAT5 STAT1 STAT6;
	BETA=ROUND(BETA, .001);
	INF=ROUND(INF, .001);
	SUP=ROUND(SUP, .001);
	EXP=ROUND(EXP, .001);
	INF_EXP=ROUND(INF_EXP, .001);
	SUP_EXP=ROUND(SUP_EXP, .001);
	Differenza=((EXP - 0.941)/0.941)*100;
	Differenza=ROUND(Differenza, .001);
	DROP LEVEL1;
RUN;

PROC PRINT DATA=CONFRONTO;
	VAR MODELLO DEVIANZA AIC EXP INF_EXP SUP_EXP DIFFERENZA;
RUN;
