* Install packages mfx2 and cibar


*********************************************************************************************
*****EXPERIMENT GHANA + TANZANIA - RELIGIOUS IDEAS AND ALTRUISM/INTERGROUP DISCRIMINATION****
****************************DOFILE FOR FIGURES IN APPENDIX********************************
*********************************************************************************************


***************************************
*** Directories				  *****
***************************************

*You can specify your datapath here:
* global datapath "XX"

*Please load the dta-file:
* use "$datapath\experiment_ajps.dta"


**********************************
*Figure A1: Histograms for share of endowment sent*
************************************
histogram fraction ,  percent addlabel addlabopts( yvarformat(%9.2f) mlabangle(forty_five) mlabgap(2)) yscale(range(0 30)) xlabel(0(.1)1) xtitle(Fraction of endowment sent) by(, legend(off) note(" ")row(2)) by(type) binrescale color(emidblue) 


***********************************
*Figure A2: Histogram of primes*
************************************
histogram state3_1 if DG_order==1 & state3_1!=0, width(0.4) percent addlabel yscale(range(0 100)) xlabel(1(1)3, angle(forty_five) valuelabel) xtitle(One true religion) addlabopts(yvarformat(%4.1f)) color(emidblue)
histogram state3_2 if DG_order==1 & state3_2!=0, width(0.4) percent addlabel yscale(range(0 100)) xlabel(1(1)3, angle(forty_five) valuelabel) xtitle(Universal love) addlabopts(yvarformat(%4.1f)) color(emidblue)
histogram state3_3 if DG_order==1 & state3_3!=0, width(0.4) percent addlabel yscale(range(0 100)) xlabel(1(1)3, angle(forty_five) valuelabel) xtitle(Control) addlabopts(yvarformat(%4.1f)) color(emidblue)


***********************************
*Figure A3: Statements prior to primes*
************************************
histogram dg_statement1 if DG_order==1 , width(0.2) percent addlabel addlabopts(yvarformat(%9.2f))  yscale(range(0 110)) xlabel(1(1)3, angle(forty_five) valuelabel) xtitle(New technologies) by(, legend(off) note(" ")) by(type) color(emidblue)
histogram dg_statement2 if DG_order==1 , width(0.2) percent addlabel addlabopts(yvarformat(%9.2f)) yscale(range(0 110)) xlabel(1(1)3, angle(forty_five) valuelabel) xtitle(New ideas and be creative) by(, legend(off) note(" ")) by(type) color(emidblue)

