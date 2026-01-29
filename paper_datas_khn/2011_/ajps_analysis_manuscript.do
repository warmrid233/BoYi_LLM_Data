* Install packages mfx2 and cibar

*********************************************************************************************
*****EXPERIMENT GHANA + TANZANIA - RELIGIOUS IDEAS AND ALTRUISM/INTERGROUP DISCRIMINATION****
****************************DOFILE FOR DATA ANALYSIS MANUSCRIPT********************************
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

***********************************************
*Table 2: Sample description and randomization*
***********************************************

*drop all observations which have missing descriptive variables
preserve
foreach var of varlist $charac $reli {
	drop  if `var'==.
}


* To calculate means and standard errors
foreach var of varlist $charac $reli {
ttest `var' if DG_order==1 & treatmentdg!=1, by (treatmentdg)
}

foreach var of varlist $charac $reli {
ttest `var' if DG_order==1 & treatmentdg!=2, by (treatmentdg)
}

foreach var of varlist $charac $reli {
ttest `var' if DG_order==1 & treatmentdg!=3, by (treatmentdg)
}


* Tests for difference
* Universal love & one true religion
foreach var of global dummy {
	prtest `var' if DG_order==1 & treatmentdg!=3, by(treatmentdg)
}
foreach var of global rest {
	ranksum `var' if DG_order==1 & treatmentdg!=3, by(treatmentdg)
}

* One true reli & control
foreach var of global dummy {
	prtest `var' if DG_order==1 & treatmentdg!=2, by(treatmentdg)
}
foreach var of global rest {
	ranksum `var' if DG_order==1 & treatmentdg!=2, by(treatmentdg)
}
* Universal love & control
foreach var of global dummy {
	prtest `var' if DG_order==1 & treatmentdg!=1, by(treatmentdg)
}
foreach var of global rest {
	ranksum `var' if DG_order==1 & treatmentdg!=1, by(treatmentdg)
}

restore



***********************************
*Table 3: General level of altruism*
************************************
xtset id DG_order

xtreg fraction treatDG1 treatDG2 samer tanz DG_order $session, re vce(cluster id)
xtreg fraction treatDG1 treatDG2 samer tanz DG_order $charac $reli $technic, re vce(cluster id)
xtreg fraction treatDG1 treatDG2 samer c.treatDG1#c.samer c.treatDG2#c.samer tanz DG_order $session, re vce(cluster id)
xtreg fraction treatDG1 treatDG2 samer c.treatDG1#c.samer c.treatDG2#c.samer tanz DG_order $charac $reli $technic, re vce(cluster id)
xttobit fraction treatDG1 treatDG2 samer c.treatDG1#c.samer c.treatDG2#c.samer tanz DG_order $session, ll(0) ul(1)
xttobit fraction treatDG1 treatDG2 samer c.treatDG1#c.samer c.treatDG2#c.samer tanz DG_order $charac $reli $technic, ll(0) ul(1)



*********************************
*Table 4: Occurrence of dicrimination (descriptives)
**********************************

* One true religion vs. control
prtest positive_discri if treatmentdg!=2 & DG_order==1, by(treatmentdg)
* Universal love vs. control
prtest positive_discri if treatmentdg!=1 & DG_order==1, by(treatmentdg)

* One true religion vs. control
prtest negative_discr if treatmentdg!=2 & DG_order==1, by(treatmentdg)
* Universal love vs. control
prtest negative_discr if treatmentdg!=1 & DG_order==1, by(treatmentdg)

* One true religion vs. control
prtest equal if treatmentdg!=2 & DG_order==1, by(treatmentdg)
* Universal love vs. control
prtest equal if treatmentdg!=1 & DG_order==1, by(treatmentdg)


*********************************
*Table 5: Occurrence of discrimination (mlogit)*
*********************************

preserve
drop if DG_order==2

mlogit discrDG treatDG1 treatDG2 tanz order $session,  vce(cluster id)
mfx2, replace
mlogit discrDG treatDG1 treatDG2 tanz order $charac $reli $technic,  vce(cluster id)
mfx2, replace
mlogit discrDG treatDG1 treatDG2 tanz order $charac $reli $technic if rounddiscr_v1==1,  vce(cluster id)
mfx2, replace

restore
