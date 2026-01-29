* Install packages mfx2, cibar and grc1leg


*********************************************************************************************
*****EXPERIMENT GHANA + TANZANIA - RELIGIOUS IDEAS AND ALTRUISM/INTERGROUP DISCRIMINATION****
****************************DOFILE FOR FIGURES IN MANUSCRIPT********************************
*********************************************************************************************


***************************************
*** Directories***
***************************************


*You can specify your datapath here:
* global datapath "XX"

*Please load the dta-file:
* use "$datapath\experiment_ajps.dta"


**********************************
*Figure 2: Fraction of endowment sent*
************************************
preserve

collapse (mean) meanfraction_dg= fraction_dg (sd) sdfraction_dg=fraction_dg (count) n=fraction_dg, by(treatmentdg)
generate hifraction_dg = meanfraction_dg + invttail(n-1,0.025)*(sdfraction_dg / sqrt(n))
generate lowfraction_dg = meanfraction_dg - invttail(n-1,0.025)*(sdfraction_dg / sqrt(n))

generate sesfraction_dg = meanfraction_dg    if treatmentdg == 1
replace  sesfraction_dg = meanfraction_dg+1.5  if treatmentdg == 2
replace  sesfraction_dg = meanfraction_dg+3 if treatmentdg == 3
sort meanfraction_dg
list sesfraction_dg ses meanfraction_dg, sepby(ses)

twoway (bar meanfraction_dg sesfraction_dg, legend(off) color(gs4)) (rcap hifraction_dg lowfraction_dg ses, yla(0(0.05)0.27) xlabel(0.25 "One true religion" 1.75 "Universal love" 3.25 "Control", noticks) xtitle("") title("Fraction of endowment sent (n=2,508)"))

restore

*************************
*Figure 3: Proportions sent in Accra and Dar es Salaam
preserve
drop if treatmentdg!=1
collapse (mean) meanfraction_dg= fraction_dg (sd) sdfraction_dg=fraction_dg (count) n=fraction_dg, by(samer type)
generate hifraction_dg = meanfraction_dg + invttail(n-1,0.025)*(sdfraction_dg / sqrt(n))
generate lowfraction_dg = meanfraction_dg - invttail(n-1,0.025)*(sdfraction_dg / sqrt(n))

generate sesfraction = meanfraction_dg    if type == 0 & samer==0
replace  sesfraction = meanfraction_dg+1  if type == 0 & samer==1
replace  sesfraction = meanfraction_dg+2.5  if type == 1 & samer==0
replace  sesfraction = meanfraction_dg+3.5  if type == 1 & samer==1

sort sesfraction
list sesfraction type samer, sepby(type)

twoway (bar meanfract sesfraction if samer==0,  barw(1) color(gs4))(bar meanfract sesfraction if samer==1,  barw(1) color(gs11))(rcap hifraction lowfraction sesfraction, xtitle("") yla(0(0.05)0.26) xlab("") legend(size(vsmall)row(2) order(1 "Other religion" 2 "Same religion"))  xlabel( 0.75 "Accra" 3.25 "Dar es Salaam", noticks) title("One true religion", size(medium)))
* Please specify in the following line "xx" (where you want to save your graph)
* graph save "xx", replace
restore

preserve
drop if treatmentdg!=2
collapse (mean) meanfraction_dg= fraction_dg (sd) sdfraction_dg=fraction_dg (count) n=fraction_dg, by(samer type)
generate hifraction_dg = meanfraction_dg + invttail(n-1,0.025)*(sdfraction_dg / sqrt(n))
generate lowfraction_dg = meanfraction_dg - invttail(n-1,0.025)*(sdfraction_dg / sqrt(n))

generate sesfraction = meanfraction_dg    if type == 0 & samer==0
replace  sesfraction = meanfraction_dg+1  if type == 0 & samer==1
replace  sesfraction = meanfraction_dg+2.5  if type == 1 & samer==0
replace  sesfraction = meanfraction_dg+3.5  if type == 1 & samer==1

sort sesfraction
list sesfraction type samer, sepby(type)

twoway (bar meanfract sesfraction if samer==0,  barw(1) color(gs4))(bar meanfract sesfraction if samer==1,  barw(1) color(gs11))(rcap hifraction lowfraction sesfraction, xtitle("") yla(0(0.05)0.26) xlab("") legend(row(2) order(1 "Other religion" 2 "Same religion"))  xlabel( 0.75 "Accra" 3.25 "Dar es Salaam", noticks) title("Universal love", size(medium)))
* Please specify in the following line "xx" (where you want to save your graph)
* graph save "xx", replace
restore

preserve
drop if treatmentdg!=3
collapse (mean) meanfraction_dg= fraction_dg (sd) sdfraction_dg=fraction_dg (count) n=fraction_dg, by(samer type)
generate hifraction_dg = meanfraction_dg + invttail(n-1,0.025)*(sdfraction_dg / sqrt(n))
generate lowfraction_dg = meanfraction_dg - invttail(n-1,0.025)*(sdfraction_dg / sqrt(n))

generate sesfraction = meanfraction_dg    if type == 0 & samer==0
replace  sesfraction = meanfraction_dg+1  if type == 0 & samer==1
replace  sesfraction = meanfraction_dg+2.5  if type == 1 & samer==0
replace  sesfraction = meanfraction_dg+3.5  if type == 1 & samer==1

sort sesfraction
list sesfraction type samer, sepby(type)

twoway (bar meanfract sesfraction if samer==0,  barw(1) color(gs4))(bar meanfract sesfraction if samer==1,  barw(1) color(gs11))(rcap hifraction lowfraction sesfraction, xtitle("") yla(0(0.05)0.26) xlab("") legend(row(2) order(1 "Other religion" 2 "Same religion"))  xlabel( 0.75 "Accra" 3.25 "Dar es Salaam", noticks) title("Control", size(medium)))
* Please specify in the following line "xx" (where you want to save your graph)
* graph save "xx", replace
restore

* Please specify in the following lines "xx" (where you want to save your graph)
* grc1leg "" "" "", xcommon ycommon rows(1)
* graph save "", replace
