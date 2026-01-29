* Install packages mfx2 and cibar


*********************************************************************************************
*****EXPERIMENT GHANA + TANZANIA - RELIGIOUS IDEAS AND ALTRUISM/INTERGROUP DISCRIMINATION****
****************************DOFILE FOR DATA ANALYSIS APPENDIX********************************
*********************************************************************************************


***************************************
*** Directories				  *****
***************************************

*You can specify your datapath here:
* global datapath "XX"

*Please load the dta-file:
* use "$datapath\experiment_ajps.dta"

************************
* Define globals       *
************************
*religion globals:
global reli muslim rel_firstidentity b4 b1 b3 b5 b6 b8 b9 b12 b13 b15
*socio-demographic globals:
global charac female age a2 living
*session globals:
global session sessionGhana1 sessionGhana2 sessionGhana3 sessionGhana4 sessionGhana5 sessionGhana6 sessionGhana7 sessionGhana8 sessionGhana9 sessionGhana10 sessionGhana11 sessionGhana12 sessionGhana13 sessionGhana14  sessionTanz1 sessionTanz2 sessionTanz3 sessionTanz4 sessionTanz5 sessionTanz6 sessionTanz7 sessionTanz8 sessionTanz9 sessionTanz10 sessionTanz11 sessionTanz12 sessionTanz13 sessionTanz14
*interviewer globals:
global interv intervdg*
*interviewer and session globals:
global technic intervdg* sessionG* sessionT*

*global for all dummy variables:
global dummy female muslim rel_firstidentity b5 b6 b15
*global for all other variables:
global rest age a2 living b4 b1 b3 b8 b9 b12 b13

************************
*Summary Characteristics*
************************

* drop all observations which have missing descriptive variables
preserve
foreach var of varlist $charac $reli {
	drop  if `var'==.
}


**********************************************************************
*Table A2: Characteristics of participants in Accra and Dar es Salaam*
**********************************************************************

***To calculate means and standard errors
foreach var of varlist $charac $reli {
ttest `var' if DG_order==1, by (type)
}


*** To test for difference
foreach var of global dummy {
	prtest `var' if DG_order==1, by(type)
}
foreach var of global rest {
	ranksum `var' if DG_order==1, by(type)
}

restore

preserve
foreach var of varlist $charac $reli {
	drop  if `var'==.
}

foreach var of varlist $charac $reli {
	mean `var' if DG_order==1
}

restore


***********************************
*Table A3: General level of altruism*
************************************
* Both rounds all
ttest fraction_dg if treatmentdg!=1, by (treatmentdg)
ttest fraction_dg if treatmentdg!=2, by (treatmentdg)
ttest fraction_dg if treatmentdg!=3, by (treatmentdg)


* Round 1 all
* To calculate means and standard errors
ttest fraction_dg if DG_order==1 & treatmentdg!=1, by (treatmentdg)
ttest fraction_dg if DG_order==1 & treatmentdg!=2, by (treatmentdg)
ttest fraction_dg if DG_order==1 & treatmentdg!=3, by (treatmentdg)


* Round 1 Ghana
*To calculate means and standard errors
ttest fraction_dg if DG_order==1 & treatmentdg!=1 & type==0, by(treatmentdg)
ttest fraction_dg if DG_order==1 & treatmentdg!=2 & type==0, by(treatmentdg)
ttest fraction_dg if DG_order==1 & treatmentdg!=3 & type==0, by(treatmentdg)

* Round 1 Tanzania
*To calculate means and standard errors
ttest fraction_dg if DG_order==1 & treatmentdg!=1 & type==1, by(treatmentdg)
ttest fraction_dg if DG_order==1 & treatmentdg!=2 & type==1, by(treatmentdg)
ttest fraction_dg if DG_order==1 & treatmentdg!=3 & type==1, by(treatmentdg)

* Round 2 all
* To calculate means and standard errors
ttest fraction_dg if DG_order==2 & treatmentdg!=1, by (treatmentdg)
ttest fraction_dg if DG_order==2 & treatmentdg!=2, by (treatmentdg)
ttest fraction_dg if DG_order==2 & treatmentdg!=3, by (treatmentdg)

* Round 2 Ghana
*To calculate means and standard errors
ttest fraction_dg if DG_order==2 & treatmentdg!=1 & type==0, by(treatmentdg)
ttest fraction_dg if DG_order==2 & treatmentdg!=2 & type==0, by(treatmentdg)
ttest fraction_dg if DG_order==2 & treatmentdg!=3 & type==0, by(treatmentdg)

* Round 2 Tanzania
*To calculate means and standard errors
ttest fraction_dg if DG_order==2 & treatmentdg!=1 & type==1, by(treatmentdg)
ttest fraction_dg if DG_order==2 & treatmentdg!=2 & type==1, by(treatmentdg)
ttest fraction_dg if DG_order==2 & treatmentdg!=3 & type==1, by(treatmentdg)

* Tests for differences
forvalues i=1/2 {
	forvalues k=1/3 {
		ranksum fraction_dg if DG_order==`i' & treatmentdg!=`k'  , by (treatmentdg)
		ranksum fraction_dg if DG_order==`i' & type==0 & treatmentdg!=`k', by (treatmentdg)
		ranksum fraction_dg if DG_order==`i' & type==1 & treatmentdg!=`k', by (treatmentdg)
	}
}

***********************************
*Table A4 : Intensity of discrimination (both countries)*
************************************
tsset id samer
gen prevfraction = L.fraction

* All treatments all countries
* To calculate means and standard errors
ttest fraction_dg, by(samer)
* Test for differences
signrank fraction_dg=pre if samer==1

* One true religion all countries
* To calculate means and standard errors
ttest fraction_dg if treatmentdg==1, by(samer)
* Test for differences
signrank fraction_dg=pre if samer==1 & treatmentdg==1

* Universal love all countries
* To calculate means and standard errors
ttest fraction_dg if treatmentdg==2, by(samer)
* Test for differences
signrank fraction_dg=pre if samer==1 & treatmentdg==2

* Control all countries
* To calculate means and standard errors
ttest fraction_dg if treatmentdg==3, by(samer)
* Test for differences
signrank fraction_dg=pre if samer==1 & treatmentdg==3


***********************************
*Table A5 : Intensity of discrimination (by country)*
************************************
******ALL TREATMENTS********
* Ghana
* To calculate means and standard errors
ttest fraction_dg if type==0, by(samer)
* Test for difference
signrank fraction_dg=pre if samer==1 & type==0

* Tanzania
* To calculate means and standard errors
ttest fraction_dg if type==1, by(samer)
* Test for difference
signrank fraction_dg=pre if samer==1 & type==1

******ONE TRUE RELIGION********
* Ghana
* To calculate means and standard errors
ttest fraction_dg if treatmentdg==1 & type==0, by(samer)
* Test for difference
signrank fraction_dg=pre if samer==1 & treatmentdg==1 & type==0

* Tanzania
* To calculate means and standard errors
ttest fraction_dg if treatmentdg==1 & type==1, by(samer)
* Test for difference
signrank fraction_dg=pre if samer==1 & treatmentdg==1 & type==1

******UNIVERSAL LOVE********
* Ghana
* To calculate means and standard errors
ttest fraction_dg if treatmentdg==2 & type==0, by(samer)
* Test for difference
signrank fraction_dg=pre if samer==1 & treatmentdg==2 & type==0

*Tanzania
* To calculate means and standard errors
ttest fraction_dg if treatmentdg==2 & type==1, by(samer)
* Test for difference
signrank fraction_dg=pre if samer==1 & treatmentdg==2 & type==1

******CONTROL********
* Ghana
* To calculate means and standard errors
ttest fraction_dg if treatmentdg==3 & type==0, by(samer)
* Test for difference
signrank fraction_dg=pre if samer==1 & treatmentdg==3 & type==0

* Tanzania
* To calculate means and standard errors
ttest fraction_dg if treatmentdg==3 & type==1, by(samer) 
* Test for difference
signrank fraction_dg=pre if samer==1 & treatmentdg==3 & type==1


******************************************************************************
* PANEL DIMENSION
*******************************************************************************

xtset id DG_order

************************
* Table A 6: Heterogeneous treatment effects for fraction of endowment sent (random effects GLS regressions)
************************
xtreg fraction treatDG1 treatDG2 samer DG_order tanz c.treatDG1#c.tan c.treatDG2#c.tan $session, re vce(cluster id)
xtreg fraction treatDG1 treatDG2 samer DG_order tanz c.treatDG1#c.muslim c.treatDG2#c.mus muslim $session, re vce(cluster id)
xtreg fraction treatDG1 c.treatDG1#c.rel_f treatDG2 c.treatDG2#c.rel_f samer tanz DG_order rel_f $session, re vce(cluster id)
xtreg fraction treatDG1 c.treatDG1#c.b1 treatDG2 c.treatDG2#c.b1 samer tanz DG_order b1 $session, re vce(cluster id)
xtreg fraction treatDG1 treatDG2  samer tanz DG_order state3_1 state3_2 $session, re vce(cluster id)

***********************************
*Table A7: Control variables for the regressions in Table 3*
************************************
xtreg fraction treatDG1 treatDG2 samer tanz DG_order $session, re vce(cluster id)
xtreg fraction treatDG1 treatDG2 samer tanz DG_order $charac $reli $technic, re vce(cluster id)
xtreg fraction treatDG1 treatDG2 samer c.treatDG1#c.samer c.treatDG2#c.samer tanz DG_order $session, re vce(cluster id)
xtreg fraction treatDG1 treatDG2 samer c.treatDG1#c.samer c.treatDG2#c.samer tanz DG_order $charac $reli $technic, re vce(cluster id)
xttobit fraction treatDG1 treatDG2 samer c.treatDG1#c.samer c.treatDG2#c.samer tanz DG_order $session, ll(0) ul(1)
xttobit fraction treatDG1 treatDG2 samer c.treatDG1#c.samer c.treatDG2#c.samer tanz DG_order $charac $reli $technic, ll(0) ul(1)

***********************************
*Table A8: Heterogenous treatment effects - agreeing to primes*
************************************
xtreg fraction treatDG1 treatDG2 samer tanz DG_order c.treatDG1#c.samer c.treatDG2#c.samer state3_1 c.treatDG1#c.samer#c.state3_1 state3_2 c.treatDG2#c.samer#c.state3_2 $session, re vce(cluster id)
xtreg fraction treatDG1 treatDG2 samer tanz DG_order c.treatDG1#c.samer c.treatDG2#c.samer state3_1 c.treatDG1#c.samer#c.state3_1 state3_2 c.treatDG2#c.samer#c.state3_2 $charac $reli $technic, re vce(cluster id)

***********************************
*Table A9: Round 1*
************************************
preserve
drop if DG_order==2

reg fraction treatDG1 treatDG2 samer tanz $session, vce(cluster id)
reg fraction treatDG1 treatDG2 samer tanz $charac $reli $technic, vce(cluster id)
reg fraction treatDG1 treatDG2 samer c.treatDG1#c.samer c.treatDG2#c.samer tanz $session, vce(cluster id)
reg fraction treatDG1 treatDG2 samer c.treatDG1#c.samer c.treatDG2#c.samer tanz $charac $reli $technic, vce(cluster id)
tobit fraction treatDG1 treatDG2 samer c.treatDG1#c.samer c.treatDG2#c.samer tanz $session, ll(0) ul(1)
tobit fraction treatDG1 treatDG2 samer c.treatDG1#c.samer c.treatDG2#c.samer tanz $charac $reli $technic, ll(0) ul(1)

restore

***********************************
*Table A10: Round 2*
************************************
preserve
drop if DG_order==1

reg fraction treatDG1 treatDG2 samer tanz $session, vce(cluster id)
reg fraction treatDG1 treatDG2 samer tanz $charac $reli $technic, vce(cluster id)
reg fraction treatDG1 treatDG2 samer c.treatDG1#c.samer c.treatDG2#c.samer tanz $session, vce(cluster id)
reg fraction treatDG1 treatDG2 samer c.treatDG1#c.samer c.treatDG2#c.samer tanz $charac $reli $technic, vce(cluster id)
tobit fraction treatDG1 treatDG2 samer c.treatDG1#c.samer c.treatDG2#c.samer tanz $session, ll(0) ul(1)
tobit fraction treatDG1 treatDG2 samer c.treatDG1#c.samer c.treatDG2#c.samer tanz $charac $reli $technic, ll(0) ul(1)

restore

***********************************
*Table A11: Controls for Table 5*
************************************
preserve
drop if DG_order==2

mlogit discrDG treatDG1 treatDG2 tanz order $session,  vce(cluster id)
mfx2, replace
mlogit discrDG treatDG1 treatDG2 tanz order $charac $reli $technic,  vce(cluster id)
mfx2, replace
mlogit discrDG treatDG1 treatDG2 tanz order $charac $reli $technic if rounddiscr_v1==1,  vce(cluster id)
mfx2, replace

restore
