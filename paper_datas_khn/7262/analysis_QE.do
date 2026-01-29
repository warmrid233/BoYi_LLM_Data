
// %ADJUST%: replace path here
cd "/Users/aziegler/surfdrive/Documents/Uni/Auction project/QE Data"

set scheme lean2
use results_QE.dta, clear

*** predicted revenue, table 1
bysort treatment: sum nashbid bidsignal sigavg brbidsignal brsigavg if sigorder == 4 & treatment < 2

*** squared distance to common value, figure 1
// see joint output in results section, figures 4 and 5

*** mean revenue, figure 2

// obtain mean cv from data
sum cv if sigorder == 1 & treatment == 1 
local meancv=r(mean)

// collapse data for graph
preserve
keep if droporder == 1
collapse (mean) meanrev = price theoryrev = nashbidfour (sd) sdrev = price sdtheory=nashbidfour (count) n = price, by(treatment)
replace theoryrev = . if treatment == 2
// obtain CIs
generate hirev = meanrev + invttail(n-1,0.025)*(sdrev / sqrt(n))
generate lowrev = meanrev - invttail(n-1,0.025)*(sdrev / sqrt(n))
generate hirevtheory = theoryrev + invttail(n-1,0.025)*(sdtheory / sqrt(n))
generate lowrevtheory = theoryrev - invttail(n-1,0.025)*(sdtheory / sqrt(n))
// to plot mean common value
gen mcv = `meancv'
// position indices for plot
gen pos = 0
replace pos = 3 if treatment == 1
replace pos = 6 if treatment == 2
// reshape data for presentation
rename meanrev rev1
rename theoryrev rev2
reshape long rev, i(treatment) j(j)
replace hirev = hirevtheory if j == 2
replace lowrev = lowrevtheory if j == 2
replace pos = 1 if treatment == 0 & j == 2
replace pos = 4 if treatment == 1 & j == 2
// generate plot
twoway 	(bar rev pos if j == 1) ///
		(bar rev pos if j == 2) ///
		(rcap hirev lowrev pos) ///
		(line mcv pos), ///
		legend(order(1 "Mean revenue" 2 "Nash prediction" 3 "95% confidence intervals" 4 "Mean common value") ) ///
		xlabel( 0 "AV" 3 "JEA" 6 "OO", noticks) ///
        ytitle("Revenue") xtitle("") ylab(90(5)115)
		
restore

*** revenue statistics and tests, table 2

// summary statistics of revenue
bysort treatment: sum price if ingroupid == 1
// separetly by first and last half
gen last15 = (round > 15)
bysort last15 treatment: sum price if ingroupid == 1

// test statistics

// tests on matchgroup(=session) level: collapse data first
preserve
collapse treatment (mean) price nashbidfour, by(session)
// main tests
// treatment effects
ranksum price if treatment < 2, by(treatment) // AV vs. JEA
ranksum price if treatment != 1, by(treatment) // AV vs. OO
ranksum price if treatment > 0, by(treatment) // JEA vs. OO

// reshape data for tests compared to NE predictions (within treatment)
rename price price1
rename nashbidfour price2
gen id = _n
reshape long price, i(id) j(j)
// test differences to NE
ranksum price if treatment == 0, by(j) // AV
ranksum price if treatment == 1, by(j) // JEA
restore

// repeat tests, separately for first and second half
preserve
keep if ingroupid == 1
collapse treatment (mean) price nashbidfour, by(session last15)

/// first and second half of the data

// treatment effects
ranksum price if treatment < 2 & last15 == 0, by(treatment)
ranksum price if treatment != 1 & last15 == 0, by(treatment)
ranksum price if treatment > 0 & last15 == 0, by(treatment)

ranksum price if treatment < 2 & last15 == 1, by(treatment)
ranksum price if treatment != 1 & last15 == 1, by(treatment)
ranksum price if treatment > 0 & last15 == 1, by(treatment)

// differences to NE
rename price price1
rename nashbidfour price2
gen i = _n
reshape long price, i(i) j(j)
ranksum price if treatment == 0 & last15 == 0, by(j)
ranksum price if treatment == 1 & last15 == 0, by(j)

ranksum price if treatment == 0 & last15 == 1, by(j)
ranksum price if treatment == 1 & last15 == 1, by(j)

restore

*** information processing in JEA, table 3

// set panel structure: ppnr is the id per subject
xtset ppnr round

// first, generate empirical best response; estimating predicted signal based on observables: signal, round, session fixed effects, if applicable predicted signals from earlier dropouts
reg signal mydrop round i.session if droporder == 1 & treatment == 1, vce(cl session)
predict sigonehat
bysort session round groupid: replace sigonehat = . if droporder != 1
sort session round groupid droporder
bysort session round groupid: replace sigonehat = sigonehat[1]

reg signal mydrop sigonehat round i.session if droporder == 2 & treatment == 1, vce(cl session)
predict sigtwohat
bysort session round groupid: replace sigtwohat = . if droporder != 2
sort session round groupid droporder
bysort session round groupid: replace sigtwohat = sigtwohat[2]

reg signal mydrop sigonehat sigtwohat round i.session if droporder == 3 & treatment == 1, vce(cl session)
predict sigthreehat
bysort session round groupid: replace sigthreehat = . if droporder != 3
sort session round groupid droporder
bysort session round groupid: replace sigthreehat = sigthreehat[3]

reg signal mydrop sigonehat sigtwohat sigthreehat round i.session if droporder == 4 & treatment == 1, vce(cl session)
predict sigfourhat
bysort session round groupid: replace sigfourhat = . if droporder != 4
sort session round groupid droporder
bysort session round groupid: replace sigfourhat = sigfourhat[4]

// average the inferred signal and the fourth dropouts' signals
gen meansignew = (sigonehat + sigtwohat + sigthreehat + 2*signal)/5 if treatment==1&droporder==4
// use formula by deGroot to calculate posterior
gen vhat =   (100/(25^2) + (5*meansignew)/(35^2))/((1/(25^2))+(5/(35^2)))

// estimate table 3

// (1)
xtreg mydrop signal round if droporder == 1 & treatment == 1, fe vce(cl session)
// (2)
xtreg mydrop signal dropone round if droporder == 2 & treatment == 1, fe vce(cl session)
// (3)
xtreg mydrop signal dropone droptwo round if droporder == 3 & treatment == 1, fe vce(cl session)
// (4)
xtreg mydrop signal dropone droptwo dropthree round if droporder == 4 & treatment == 1, fe vce(cl session)
// test coefficient restricitons implied by the models in equation of fourth dropout, footnote 26
test (dropone=0.1) (droptwo=0.167) (dropthree=.333) (signal=.287) (_cons=11.265)  //nash
test (dropone=0) (droptwo=0) (dropthree=.75) (signal=.25) (_cons=0) //sa
test (dropone=0) (droptwo=0) (dropthree=.832) (signal=.168) (_cons=0)  //bsa
// (5)
reg nashbid signal nashbidone nashbidtwo nashbidthree if sigorder == 4 & treatment == 1
// (6)
reg sigavg signal sigavgone sigavgtwo sigavgthree  if sigorder == 4 & treatment == 1
// (7)
reg brsigavg brsigavgone brsigavgtwo brsigavgthree signal if sigorder == 4 & treatment ==1
// (8)
reg cv signal dropone droptwo dropthree round if treatment==1 & droporder  == 4, vce(cl session)
// (9)	
reg vhat signal dropone droptwo dropthree round if treatment==1 & droporder  == 4, vce(cl session)

// calculate adjusted r-squared abs. i for (1) to (4), which includes the fit from subject fixed effects
areg mydrop signal round if droporder == 1 & treatment == 1,  absorb(ppnr) vce(cl session)				
areg mydrop signal dropone round if droporder == 2 & treatment == 1,  absorb(ppnr) vce(cl session)
areg mydrop signal dropone droptwo round if droporder == 3 & treatment == 1,  absorb(ppnr) vce(cl session)				
areg mydrop signal dropone droptwo dropthree round if droporder == 4 & treatment == 1,  absorb(ppnr) vce(cl session)

// repeat (4) and (8) with additional regressors signal squared and dropthree squared, footnote 24
gen signalsq=signal^2
gen dropthreesq=dropthree^2

reg cv signal signalsq dropone droptwo dropthree round if treatment==1 & droporder  == 4, vce(cl session)
xtreg mydrop signal signalsq dropone droptwo dropthree round if droporder == 4 & treatment == 1, fe vce(cl session)

reg cv signal dropone droptwo dropthree dropthreesq round if treatment==1 & droporder  == 4, vce(cl session)
xtreg mydrop signal dropone droptwo dropthree dropthreesq round if droporder == 4 & treatment == 1, fe vce(cl session)

// AV statistics on bid relative to signal for signal greater or smaller 100
gen bidrelsignal = mydrop/signal
sum bidrelsignal if treatment==0 & signal<=100 & droporder<5 // condition: in AV, signal at most 100, actively observed dropout (orders 1-4)
sum bidrelsignal if treatment==0 & signal>100 & droporder<5 // condition: same, but signal greater 100

// repeat (8) with squared round and round fixed effect, footnote 27
gen roundsq = round^2
reg cv signal dropone droptwo dropthree round roundsq if treatment==1 & droporder  == 4, vce(cl session)
reg cv signal dropone droptwo dropthree i.round if treatment==1 & droporder  == 4, vce(cl session)


** comparing information use in the AV and the JEA, table 4

// repeat (2) to (4), but interacted with treatment; table 4 only contains b_{j-1} estimates, while the full of the table is reported in the appendix
use results_QE.dta, clear
xtset ppnr round
xtreg mydrop c.signal##treatment c.dropone##treatment c.round##treatment if treatment < 2 & droporder == 2, vce(cl session) fe
display e(r2_a) // adjusted r-squared for table 4
xtreg mydrop c.signal##treatment c.dropone##treatment c.droptwo##treatment c.round##treatment if treatment < 2 & droporder == 3, vce(cl session) fe
display e(r2_a)
xtreg mydrop c.signal##treatment c.dropone##treatment c.droptwo##treatment c.dropthree##treatment c.round##treatment if treatment < 2 & droporder == 4, vce(cl session) fe
display e(r2_a)
	
** summary measures of SVO and imitator, within text of section 6.3

use results_QE.dta, clear
preserve
// only last sessions with these measures
drop if infosource==.
drop if angledeg==.
// obtain statistics
sum infosource angledeg
restore
	
** bidder fixed effects and their characteristics, table 5

xtset ppnr round
// obtain average fixed effects at each dropout order, starting with first and second order for the JEA
fese mydrop signal round if droporder == 1 & treatment == 1, s(fe1_) vce(cl session) a(ppnr) // equivalent to equation (1) from table 3
egen meanfe1b = mean(fe1_b) if treatment==1&droporder==1 // average fixed effect across all participants, for demeaning
replace fe1_b = fe1_b - meanfe1b if treatment==1&droporder==1 // this demeans the fixed effect
fese mydrop signal dropone round if droporder == 2  & treatment == 1, s(fe2_) vce(cl session) a(ppnr) // continue with equation (2)
egen meanfe2b = mean(fe2_b) if treatment==1&droporder==2
replace fe2_b = fe2_b - meanfe2b if treatment==1&droporder==2
// merge first and second dropout fixed effect per bidder (mean and SD, for WLS)
replace fe1_b = fe2_b if droporder==2
replace fe1_crse = fe2_crse if droporder==2
// fixed effects for third and fourth order
fese mydrop signal dropone droptwo round if droporder == 3 & treatment == 1, s(fe3_) vce(cl session) a(ppnr)
egen meanfe3b = mean(fe3_b) if treatment==1&droporder==3
replace fe3_b = fe3_b - meanfe3b if treatment==1&droporder==3
fese mydrop signal dropone droptwo dropthree round if droporder == 4 & treatment == 1, s(fe4_) vce(cl session) a(ppnr)
egen meanfe4b = mean(fe4_b) if treatment==1&droporder==4
replace fe4_b = fe4_b - meanfe4b if treatment==1&droporder==4
replace fe3_b = fe4_b if droporder==4
replace fe3_crse = fe4_crse if droporder==4
// repeat procedure for the AV
fese mydrop signal round if droporder == 1 & treatment == 0, s(fe1sp_) vce(cl session) a(ppnr)
egen meanfe1sp = mean(fe1sp_b) if treatment==0&droporder==1
replace fe1sp_b = fe1sp_b - meanfe1sp if treatment==0&droporder==1
fese mydrop signal round if droporder == 2  & treatment == 0, s(fe2sp_) vce(cl session) a(ppnr)
egen meanfe2sp = mean(fe2sp_b) if treatment==0&droporder==2
replace fe2sp_b = fe2sp_b - meanfe2sp if treatment==0&droporder==2
replace fe1sp_b = fe2sp_b if droporder==2
replace fe1sp_crse = fe2sp_crse if droporder==2
fese mydrop signal round if droporder == 3 & treatment == 0, s(fe3sp_) vce(cl session) a(ppnr)
egen meanfe3sp = mean(fe3sp_b) if treatment==0&droporder==3
replace fe3sp_b = fe3sp_b - meanfe3sp if treatment==0&droporder==3
fese mydrop signal round if droporder == 4 & treatment == 0, s(fe4sp_) vce(cl session) a(ppnr)
egen meanfe4sp = mean(fe4sp_b) if treatment==0&droporder==4
replace fe4sp_b = fe4sp_b - meanfe4sp if treatment==0&droporder==4
replace fe3sp_b = fe4sp_b if droporder==4
replace fe3sp_crse = fe4sp_crse if droporder==4
// generate average fixed effect for first and second order (mfix) and third and fourth order (mfix2), average on subject order, both for mean and SD
bysort ppnr: egen mfix = mean(fe1_b)
bysort ppnr: egen mfix2 = mean(fe3_b)
bysort ppnr: egen mfixsd = mean(fe1_crse)
bysort ppnr: egen mfix2sd = mean(fe3_crse)
// repeat procedure for AV
bysort ppnr: egen mfixsp = mean(fe1sp_b)
bysort ppnr: egen mfix2sp = mean(fe3sp_b)
bysort ppnr: egen mfixsdsp = mean(fe1sp_crse)
bysort ppnr: egen mfix2sdsp = mean(fe3sp_crse)
// replace values for AV observation in original variable
replace mfix = mfixsp if treatment == 0
replace mfix2 = mfix2sp if treatment == 0
replace mfixsd = mfixsdsp if treatment == 0
replace mfix2sd = mfix2sdsp if treatment == 0
keep if treatment < 2 // only AV and JEA are relevant
collapse session treatment (mean) mfix mfix2 mfixsd mfix2sd angledeg infosource, by(ppnr) // collapse data
// estimate table 5
// (1)
reg mfix angledeg infosource if treatment==0, vce(cl session)
// (2)
reg mfix angledeg infosource if treatment==1, vce(cl session)
// (3)
reg mfix2 angledeg infosource if treatment==0, vce(cl session)
// (4)
reg mfix2 angledeg infosource if treatment==1, vce(cl session)

// in-text statistics on bids by above- and below-median SVO at the start
use results_QE.dta, clear
preserve
drop if angledeg==. // drop observations with missing measurement (first sessions)
// median split in SVO
bysort treatment: egen med_svo = median(angledeg)
gen abovemed = (angledeg>med_svo)
// keep only bidders at start in JEA and AV
keep if droporder < 3
keep if treatment < 2
collapse (mean) mydrop, by(treatment session abovemed)
// summary statistics
bysort abovemed treatment: sum mydrop
// perform tests
ranksum mydrop if abovemed==0, by(treatment)
ranksum mydrop if abovemed==1, by(treatment)
restore

** SVO by dropout order, figure 3
drop if angledeg==.
drop if treatment==2
preserve
// keep only subjects with measurement of SVO, in AV and JEA
collapse (mean) angledeg infosource (sd) sdangle = angledeg (count) n=angledeg, by(treatment droporder)
label define treatlab 0 "AV" 1 "JEA"
label value treatment treatlab
// generate CI
generate hiangle = angledeg + invttail(n-1,0.025)*(sdangle / sqrt(n))
generate lowangle = angledeg - invttail(n-1,0.025)*(sdangle / sqrt(n))
// generate plot
twoway (bar angledeg droporder,  fc(dimgray) lc(gray)) (rcap hiangle lowangle droporder), by(treatment, note(" ")) ylab(14(2)26) ytitle("SVO") xtitle("Dropout order") subtitle(, bcolor(white)) xlab(1(1)5) legend(order(1 "Mean SVO" 2 "95% confidence interval") c(2))
restore

** in-text statistics on dropping out first or last vs. in the middle

preserve
gen middle=0
replace middle=1 if droporder > 1 & droporder < 5
// median split in SVO
bysort treatment: egen med_svo = median(angledeg)
gen abovemed = (angledeg>med_svo)
collapse (mean) middle, by(abovemed session treatment)
// testing differences by treatment
bysort treatment: ranksum middle, by(abovemed)
restore

** treatment effect on difference: logit of this difference, footnote 36
preserve
gen middle=0
replace middle=1 if droporder > 1 & droporder < 5
bysort treatment: egen med_svo = median(angledeg)
gen abovemed = (angledeg>med_svo)
// run logit
logit middle c.angledeg##treatment c.signal##treatment infosource##treatment, cl(session)
restore

** squared distance to common value, figures 1, 4 and 5

use results_QE.dta, clear

// first, prepare some analysis, e.g. obtaining empirical best response, calculate upper/lower bound
// lower bound: prior mean of value of 100
gen lowerbound = 100
// upper bound: bayesian posterior of the value, conditional on all signals
bysort session round groupid: egen meansig = mean(signal)
gen upperbound =  (100/(25^2) + (5*meansig)/(35^2))/((1/(25^2))+(5/(35^2)))
// repeat signal prediction estimations for empirical best response; first with subject fixed effects 
areg signal mydrop round  if droporder == 1 & treatment == 1, vce(cl session)  a(ppnr)
predict sigonehat, xbd
bysort session round groupid: replace sigonehat = . if droporder != 1
sort session round groupid droporder
bysort session round groupid: replace sigonehat = sigonehat[1]

areg signal mydrop sigonehat round  if droporder == 2 & treatment == 1, vce(cl session) a(ppnr)
predict sigtwohat, xbd
bysort session round groupid: replace sigtwohat = . if droporder != 2
sort session round groupid droporder
bysort session round groupid: replace sigtwohat = sigtwohat[2]

areg signal mydrop sigonehat sigtwohat round  if droporder == 3 & treatment == 1, vce(cl session) a(ppnr)
predict sigthreehat , xbd
bysort session round groupid: replace sigthreehat = . if droporder != 3
sort session round groupid droporder
bysort session round groupid: replace sigthreehat = sigthreehat[3]

// calculate bayesian posterior, first average signal
gen ne_predmeansig = (sigonehat+sigtwohat+sigthreehat+signal+signal)/5 if droporder==4
// replace predictions for full group
sort session groupid round ne_predmeansig
bysort session groupid round: replace ne_predmeansig=ne_predmeansig[1]
// calculate posterior w/ deGroot
gen ne_pred =  (100/(25^2) + (5*ne_predmeansig)/(35^2))/((1/(25^2))+(5/(35^2)))

// second signal predictions, with session fixed effects
areg signal mydrop round  if droporder == 1 & treatment == 1, vce(cl session)  a(session)
predict sigonehatsess, xbd
bysort session round groupid: replace sigonehatsess = . if droporder != 1
sort session round groupid droporder
bysort session round groupid: replace sigonehatsess = sigonehatsess[1]

areg signal mydrop sigonehatsess round  if droporder == 2 & treatment == 1, vce(cl session) a(session)
predict sigtwohatsess, xbd
bysort session round groupid: replace sigtwohatsess = . if droporder != 2
sort session round groupid droporder
bysort session round groupid: replace sigtwohatsess = sigtwohatsess[2]

areg signal mydrop sigonehatsess sigtwohatsess round  if droporder == 3 & treatment == 1, vce(cl session) a(session)
predict sigthreehatsess , xbd
bysort session round groupid: replace sigthreehatsess = . if droporder != 3
sort session round groupid droporder
bysort session round groupid: replace sigthreehatsess = sigthreehatsess[3]

// calculate bayesian posterior, copy predictions and predict posterior
gen ne_predmeansigsess = (sigonehatsess+sigtwohatsess+sigthreehatsess+signal+signal)/5 if droporder==4
sort session groupid round ne_predmeansigsess
bysort session groupid round: replace ne_predmeansigsess=ne_predmeansigsess[1]
gen ne_predsess =  (100/(25^2) + (5*ne_predmeansigsess)/(35^2))/((1/(25^2))+(5/(35^2)))

// empirical best response for OO (figure 5) 
drop sigonehat sigtwohat sigthreehat
areg signal mydrop round if droporder == 1 & treatment == 2, vce(cl session)  a(session)
predict sigonehat, xbd
bysort session round groupid: replace sigonehat = . if droporder != 1
sort session round groupid droporder
bysort session round groupid: replace sigonehat = sigonehat[1]

areg signal mydrop sigonehat round if droporder == 2 & treatment == 2, vce(cl session)  a(session)
predict sigtwohat, xbd
bysort session round groupid: replace sigtwohat = . if droporder != 2
sort session round groupid droporder
bysort session round groupid: replace sigtwohat = sigtwohat[2]

areg signal mydrop sigonehat sigtwohat round if droporder == 3 & treatment == 2, vce(cl session) a(session)
predict sigthreehat, xbd
bysort session round groupid: replace sigthreehat = . if droporder != 3
sort session round groupid droporder
bysort session round groupid: replace sigthreehat = sigthreehat[3]

gen ne_predmeansigoo = (sigonehat+sigtwohat+sigthreehat+signal+signal)/5 if droporder==4
sort session groupid round ne_predmeansigoo
bysort session groupid round: replace ne_predmeansigoo=ne_predmeansigoo[1]

gen ne_predoo =  (100/(25^2) + (5*ne_predmeansigoo)/(35^2))/((1/(25^2))+(5/(35^2)))

// keep only price setter for theoretical predictions
keep if sigorder==4

// generate distances to common value
gen distbidsig=(cv-bidsignal)^2 // distance to bid signal
gen distbaysigavg=(cv-brsigavg)^2 // distance to bay. sig. averaging
gen distnash = (cv-nashbid)^2 // distance to Nash equilibrium
gen distprice = (cv-price)^2 // distance to price in the experiment
gen distlower=(cv-lowerbound)^2 // distance to the lower bound 
gen distupper=(cv-upperbound)^2 // distance to the upper bound
gen dist_br = (cv-ne_pred)^2 // distance to empirical best response, observing subject fixed effects
gen dist_broo = (cv-ne_predoo)^2 // distance to emp. best response in OO
gen dist_br_sess= (cv-ne_predsess)^2 // distance to empirical best response, using only session fixed effects
// generate statistics
bysort treatment: sum dist*
collapse treatment (mean) dist_br dist_br_sess distprice, by(session)
// testing info aggregation in AV vs JEA, reported within text
ranksum distprice if treatment < 2, by(treatment)
// testing differences observing subject fixed effects for empirical vs. only session fixed effect for JEA, within text
signrank dist_br=dist_br_sess if treatment==1


** oral outcry auctions

use results_QE.dta, clear
** auction fever outcomes, reported in text
preserve
gen cvhigh = (cv>150) // extreme common value draw, above 150
gen revhigh = (price>150) // extreme price realization, above 150
keep if ingroupid==1 // keep 1 observation per group
bysort treatment: sum cvhigh revhigh // summary statistics
restore

** endowment effect in oral outcry auction, reported in text
// generate measure of endowment effect: average of two standarized questionnaire responses
preserve
keep if q13!=.
// standardize variables
sum q13
local q13mean=r(mean)
local q13sd=r(sd)
gen q13_standard=(q13-`q13mean')/`q13sd'
sum q14
local q14mean=r(mean)
local q14sd=r(sd)
gen q14_standard=(q14-`q14mean')/`q14sd'
// generate average
gen endow=(q13_standard+q14_standard)/2
// generate dependent variables: number of auctions won and average profit
bysort ppnr: egen wins = sum(decision)
gen earn=0
replace earn=profit if decision==1
bysort ppnr: egen totearn = sum(earn)
// keep 1 observation per subject
keep if round == 30 & treatment == 2 & session > 21
// median split on endowment effect
sum endow, d
local medendow=r(p50)
gen highendow=(endow>=`medendow')
// collapse data: per session, one group each above- and below-median endowment effect
collapse (mean) wins totearn, by(session highendow)
// test difference between groups
ranksum totearn, by(highendow)
ranksum wins, by(highendow)
restore

** robustness using principal components
preserve
keep if q13!=.
// generate principal components
pca q13 q14
predict pc1, score
// generate median split
sum pc1, d
local medpc1=r(p50)
gen highendow=(pc1>=`medpc1')
// generate dependent variables: number of auctions won and average profit
bysort ppnr: egen wins = sum(decision)
gen earn=0
replace earn=profit if decision==1
bysort ppnr: egen totearn = sum(earn)
// keep 1 observation per subject
keep if round == 30 & treatment == 2 & session > 21
// collapse data: per session, one group each above- and below-median endowment effect
collapse (mean) wins totearn, by(session highendow)
// test difference between groups
ranksum totearn, by(highendow)
ranksum wins, by(highendow)
restore

** jump bidding analysis

use oo_QE.dta, clear

** descriptive statistics, within the text
// generate jumps greater than 20 or 50
gen largejump=(jump>=20) 
gen largejump2=(jump>=50)
// summary statistics on general jump bids
sum largejump*
// summary statistics on jump bids at the start
sum largejump* if currentprice==0
// summary statistics on jump bidding at the start over time
keep if currentprice == 0 // keep only jump bids submitted at the start
gen first15=(round<16) // 
collapse (mean) jump, by(session first15)
bysort first15: sum jump

** effect of jump bids in the OO, table 6

use oo_QE.dta, clear

// start by generating instruments

// first, generate variable total jump bid (sum of increments)
bysort round ppnr: egen totjump = sum(jump) // total jump per bidder within one round
// generate the instruments: mean total jump in other periods, max bid increment in other periods
// variables for the instruments
gen maxjumpiv=.
gen totjumpiv=.
quietly levelsof ppnr, local(ppnumber)
foreach j of local ppnumber { // loop through each subject
	quietly levelsof round if ppnr==`j', local(rounds) 
	foreach i of local rounds { // per subject, loop through every round
		// first, generate the max bid increment: what's the max jump in any period but the current one?
		quietly su jump if  round!=`i' & ppnr==`j'		
		local maxjumpiv = r(max)
		// save it into current period
		quietly replace maxjumpiv = `maxjumpiv' if round==`i' & ppnr==`j'
		
		// second, mean total jump in other periods
		quietly su totjump if round!=`i' & ppnr==`j'		
		local totjumpiv = r(mean)
		quietly replace totjumpiv = `totjumpiv' if round==`i' & ppnr==`j'
		
	}
}



// estimate table 6
// (1)
reg totjump signal round  if bidcount == bidnr, vce(cl session)
display `e(r2_a)' // adjusted r-squared
// (2)
replace decision=decision*100 // rescale binary variable for interpretation as a probability
ivreg2 decision  (totjump = maxjumpiv totjumpiv) signal if bidcount == bidnr, first cluster(session) 
display `e(jp)' // Hansen J-statistic
display `e(widstat)' // Kleibergen-Paap F-statistic
display `e(r2_a)' // adj. R-squared
replace decision=decision/100 // rescale back
// (3)
ivreg2 profit  (totjump = maxjumpiv totjumpiv) signal cv round if bidcount == bidnr, cluster(session)  first
display `e(jp)'
display `e(widstat)'
display `e(r2_a)'
// (4)
ivreg2 profit  (totjump = maxjumpiv totjumpiv) signal cv round if bidcount == bidnr & decision == 1, cluster(session)  first 
display `e(jp)'
display `e(widstat)'
display `e(r2_a)'

** correlates of jump bidding tendency with questionnaire measures, footnote 41
keep if q5!=.
reg firstjump signal round q5 q6 q7 q8 q9 q10 q11 q12 if bidcount == bidnr, vce(cl session)
