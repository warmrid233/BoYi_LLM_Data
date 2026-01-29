clear all

//Friedman test package
net install snp2_1.pkg
//Package to plot with confidence intervals
ssc install eclplot

//Open Raw Data
use "RawData.dta"

//Create variable normalized allocation share 
forvalues x=1/4{
	gen share`x'=allocation`x'/tokens
}

//Create indicator variable for first half of the experiment
gen first_half= (period<=10)

********************************************************************************
********************************** Main Text ***********************************
********************************************************************************


*** Friedman test position effects *** (p.11)
preserve

//Create variable of allocation by position 
forvalues x=1/4{
	gen sloc`x'=0
		forvalues y=1/4{
			replace sloc`x'=share`y' if battle`y'location==`x'
		}
}

collapse sloc1 sloc2 sloc3 sloc4 battle1location, by (id treatment)

//All treatments
friedman sloc?

//Each treatment separately
forvalues i=1(1)7{
friedman sloc? if treatment==`i'
}

restore

*** Wilcoxon Signed rank tests non-salient are equal across battlefields*** (p.11)
preserve

gen remaining=(1-share1)/3

collapse share2 share3 share4 remaining, by (id treatment)

forvalues i=1(1)7{
	forvalues j=2(1)4{
signrank share`j'=remaining if treatment==`i'
}
}

restore


*** Table 3: Summary statistics ***
//All Periods
matrix Table3 = J(21, 7, .)
matrix colnames Table3 = "IS" "IF" "IV" "IL" "AS" "AF" "AV"
matrix rownames Table3 = "All" "N" "Mean" "std. dev." "25 percent" "50 percent (median)" "75 percent" "1-10" "N" "Mean" "std. dev." "25 percent" "50 percent (median)" "75 percent" "11-20" "N" "Mean" "std. dev." "25 percent" "50 percent (median)" "75 percent"

preserve
keep if tokens==200
collapse share1, by (id treatment)
forvalues c=1(1)7{
quietly: summ share1 if treatment==`c', detail
matrix Table3[2,`c'] = round(r(N),.001)
matrix Table3[3,`c'] = round(r(mean),.001)
matrix Table3[4,`c'] = round(r(sd),.001)
matrix Table3[5,`c'] = round(r(p25),.001)
matrix Table3[6,`c'] = round(r(p50),.001)
matrix Table3[7,`c'] = round(r(p75),.001)
}
restore

//1st half & 2nd Half
preserve
keep if tokens==200
collapse share1, by (id treatment first_half)

forvalues c=1(1)7{
quietly: summ share1 if treatment==`c' & first_half==1, detail
matrix Table3[9,`c'] = round(r(N),.001)
matrix Table3[10,`c'] = round(r(mean),.001)
matrix Table3[11,`c'] = round(r(sd),.001)
matrix Table3[12,`c'] = round(r(p25),.001)
matrix Table3[13,`c'] = round(r(p50),.001)
matrix Table3[14,`c'] = round(r(p75),.001)
}

forvalues c=1(1)7{
quietly: summ share1 if treatment==`c' & first_half==0, detail
matrix Table3[16,`c'] = round(r(N),.001)
matrix Table3[17,`c'] = round(r(mean),.001)
matrix Table3[18,`c'] = round(r(sd),.001)
matrix Table3[19,`c'] = round(r(p25),.001)
matrix Table3[20,`c'] = round(r(p50),.001)
matrix Table3[21,`c'] = round(r(p75),.001)
}
restore

matrix list Table3

*** Footnote 18: Anova and Kruskal-Wallis test all treatments have the same mean***
//All periods
preserve
keep if tokens==200
collapse share1, by(id treatment)
oneway share1 treatment
kwallis share1, by(treatment)
restore
//1st half & 2nd half
preserve
keep if tokens==200
collapse share1, by(id treatment first_half)
bysort first_half: oneway share1 treatment
//Kwallis test cannot be combined with bysort
kwallis share1 if first_half==1, by(treatment)
kwallis share1 if first_half==0, by(treatment)
restore

*** Table 4: Individual changes between 1st and 2nd half of the session ***
matrix Table4 = J(10, 7, .)
matrix colnames Table4 = "IS" "IF" "IV" "IL" "AS" "AF" "AV"
matrix rownames Table4 = "Change in Means" "mean" "median" "t-test" "signed rank" "Change in std dev" "mean" "median" "t-test" "signed rank" 

//mean & median change in means
preserve
keep if tokens==200
collapse (mean) share1, by(id treatment first_half)
reshape wide share1, i(id) j(first_half)
gen diff=share10-share11

forvalues c=1(1)7{
quietly: summ diff if treatment==`c', detail
matrix Table4[2,`c'] = round(r(mean),.001)
matrix Table4[3,`c'] = round(r(p50),.001)
}
//test means
forvalues c=1(1)7{
quietly: ttest share10=share11 if treatment==`c'
matrix Table4[4,`c'] = round(r(p),.001)
}

forvalues c=1(1)7{
quietly: signrank share10=share11 if treatment==`c'
matrix Table4[5,`c'] = round(r(p),.001)
}
restore

//mean & median change in dispersion
preserve
keep if tokens==200
collapse (sd) share1, by(id treatment first_half)
reshape wide share1, i(id) j(first_half)
gen diff=share10-share11

forvalues c=1(1)7{
quietly: summ diff if treatment==`c', detail
matrix Table4[7,`c'] = round(r(mean),.001)
matrix Table4[8,`c'] = round(r(p50),.001)
}
//test means
forvalues c=1(1)7{
quietly: ttest share10=share11 if treatment==`c'
matrix Table4[9,`c'] = round(r(p),.001)
}

forvalues c=1(1)7{
quietly: signrank share10=share11 if treatment==`c'
matrix Table4[10,`c'] = round(r(p),.001)
}
restore

matrix list Table4


*** Figure 3: Mean allocation share and confidence intervals *** 
preserve
keep if tokens==200
collapse (mean) share1, by (treatment id)
gen seshare1=share1
collapse (mean) share1 (semean) seshare1, by(treatment)
gen min=share1-(1.96*seshare1)
gen max=share1+(1.96*seshare1)
eclplot share1 min max treatment, ylabel(.18(.02).38) xlabel(1 "IS" 2 "IF" 3 "IV" 4 "IL" 5 "AS" 6 "AF" 7 "AV") yline(0.225, lpattern(dash) lcolor(red)) yline(0.25, lpattern(dash) lcolor(blue)) yline(0.275, lpattern(dash) lcolor(black))
graph export mean_ind.png, replace
restore

*** Table 5: difference between symmetric and weak players ***
matrix Table5 = J(6, 3, .)
matrix colnames Table5 = "1-10" "11-20" "All" 
matrix rownames Table5 = "t-test IS&AS" "rank sum IS&AS" "t-test IF&AF" "rank sum IF&AF" "t-test IV&AV" "rank sum IV&AV"

//1-10
//T-tests 
preserve
drop if treatment>=4 & tokens==200
drop if first_half==0
collapse share1, by(id treatment tokens)
reshape wide share1, i(id) j(treatment)
quietly: ttest share11==share15, unp
matrix Table5[1,1] = round(r(p),.01)
quietly: ttest share12==share16, unp
matrix Table5[3,1] = round(r(p),.01)
quietly: ttest share13==share17, unp
matrix Table5[5,1] = round(r(p),.01)
restore

//Ranksum
forvalues x=1/3{
    preserve
		drop if first_half==0
		drop if treatment!=`x' & treatment!=`x'+4 
		drop if treatment==`x'+4 & tokens==200
		collapse share1, by(id treatment tokens)
		quietly: ranksum share1, by(treatment)
		matrix Table5[`x'*2,1] = round(r(p),.01)
	restore
}

//11-20
//T-tests 
preserve
drop if treatment>=4 & tokens==200
drop if first_half==1
collapse share1, by(id treatment tokens)
reshape wide share1, i(id) j(treatment)
quietly: ttest share11==share15, unp
matrix Table5[1,2] = round(r(p),.01)
quietly: ttest share12==share16, unp
matrix Table5[3,2] = round(r(p),.01)
quietly: ttest share13==share17, unp
matrix Table5[5,2] = round(r(p),.01)
restore

//Ranksum
forvalues x=1/3{
    preserve
		drop if first_half==1
		drop if treatment!=`x' & treatment!=`x'+4 
		drop if treatment==`x'+4 & tokens==200
		collapse share1, by(id treatment tokens)
		quietly: ranksum share1, by(treatment)
		matrix Table5[`x'*2,2] = round(r(p),.01)
	restore
}

//All
//T-tests 
preserve
drop if treatment>=4 & tokens==200
collapse share1, by(id treatment tokens)
reshape wide share1, i(id) j(treatment)
quietly: ttest share11==share15, unp
matrix Table5[1,3] = round(r(p),.01)
quietly: ttest share12==share16, unp
matrix Table5[3,3] = round(r(p),.01)
quietly: ttest share13==share17, unp
matrix Table5[5,3] = round(r(p),.01)
restore

//Ranksum
forvalues x=1/3{
    preserve
		drop if treatment!=`x' & treatment!=`x'+4 
		drop if treatment==`x'+4 & tokens==200
		collapse share1, by(id treatment tokens)
		quietly: ranksum share1, by(treatment)
		matrix Table5[`x'*2,3] = round(r(p),.01)
	restore
}

matrix list Table5

*** Table 6: Difference between strong and weak players ***
matrix Table6 = J(5, 3, .)
matrix colnames Table6 = "1-10" "11-20" "All" 
matrix rownames Table6 = "Mean" "Median" "std dev" "t-test" "signed rank"

//1-10
preserve
drop if treatment<5 | first_half==0
collapse share1, by(treatment session tokens)
reshape wide share1, i(session) j(tokens)
gen diff=share1200-share1160
quietly: summ diff, detail
matrix Table6[1,1] = round(r(mean),.0001)
matrix Table6[2,1] = round(r(p50),.0001)
matrix Table6[3,1] = round(r(sd),.001)

quietly: ttest diff=0
matrix Table6[4,1] = round(r(p),.01)

quietly: signrank share1160=share1200
matrix Table6[5,1] = round(r(p),.01)

restore

//11-20
preserve
drop if treatment<5 | first_half==1
collapse share1, by(treatment session tokens)
reshape wide share1, i(session) j(tokens)
gen diff=share1200-share1160
quietly: summ diff, detail
matrix Table6[1,2] = round(r(mean),.0001)
matrix Table6[2,2] = round(r(p50),.0001)
matrix Table6[3,2] = round(r(sd),.001)

quietly: ttest diff=0
matrix Table6[4,2] = round(r(p),.01)

quietly: signrank share1160=share1200
matrix Table6[5,2] = round(r(p),.01)

restore

//All
preserve
drop if treatment<5
collapse share1, by(treatment session tokens)
reshape wide share1, i(session) j(tokens)
gen diff=share1200-share1160
quietly: summ diff, detail
matrix Table6[1,3] = round(r(mean),.0001)
matrix Table6[2,3] = round(r(p50),.0001)
matrix Table6[3,3] = round(r(sd),.001)

quietly: ttest diff=0
matrix Table6[4,3] = round(r(p),.01)

quietly: signrank share1160=share1200
matrix Table6[5,3] = round(r(p),.01)

restore

matrix list Table6

*** Table 7: Deviations in Expected Payoffs ***
matrix Table7 = J(7, 4, .)
matrix colnames Table7 = "(1)" "(2)" "(3)" "(4)"
matrix rownames Table7 = "IS" "IF" "IV" "IL" "AS" "AF" "AV"

preserve
//Calculate actual expected payoff
gen p1 = 1/2 if allocation1 + partnerallocation1 == 0
replace p1 = allocation1/ (allocation1 + partnerallocation1) if allocation1 + partnerallocation1 != 0
gen p2 = 1/2 if allocation1 + partnerallocation1 == tokens+partnertokens
replace p2 = (tokens-allocation1)/((tokens-allocation1)+(partnertokens-partnerallocation1)) if allocation1 + partnerallocation1 != tokens+partnertokens

gen exp_payoff= battle1value*p1 + 3*battle2value*p2

//Column (1)
gen payoff_distance_eq = 0
replace payoff_distance_eq = abs(exp_payoff - 30) if treatment<=4 
replace payoff_distance_eq = abs(exp_payoff - 33.3333) if treatment>4

forvalues c=1(1)7{
quietly: summ payoff_distance_eq if tokens==200 & treatment==`c'
matrix Table7[`c',1] = round(r(mean),.001)
}

//Declare Equilibrium strategies for the other player
gen allocation_OEQ = .
replace allocation_OEQ = 50 if (treatment==1 | treatment==2) 
replace allocation_OEQ = 55 if treatment==3 
replace allocation_OEQ = 45 if treatment==4
replace allocation_OEQ = 40 if (treatment==5 | treatment==6) 
replace allocation_OEQ = 44 if treatment==7 

//Calculate expected payoff associated to other subject playing equilibrium
gen p1_OEQ = allocation1/ (allocation1 + allocation_OEQ)
gen p2_OEQ = (tokens-allocation1)/((tokens-allocation1)+(partnertokens-allocation_OEQ))

gen exp_payoff_OEQ= battle1value*p1_OEQ + 3*battle2value*p2_OEQ

//Column (2)
gen payoff_distance_OEQ = exp_payoff_OEQ - 30 if treatment<=4
replace payoff_distance_OEQ = exp_payoff_OEQ - 33.3333 if treatment>4

forvalues c=1(1)7{
quietly: summ payoff_distance_OEQ if tokens==200 & treatment==`c'
matrix Table7[`c',2] = round(r(mean),.001)
}


//Declare Equilibrium strategies for the player
gen allocation_EQ = .
replace allocation_EQ = 50 if (treatment==1 | treatment==2 | treatment==5 | treatment==6) & tokens==200
replace allocation_EQ = 55 if (treatment==3 | treatment==7) & tokens==200
replace allocation_EQ = 45 if treatment==4 & tokens==200

//Calculate expected payoff of playing equilibrium given the other subject's actual plays
gen p1_EQ = allocation_EQ/ (allocation_EQ + partnerallocation1)
gen p2_EQ = (tokens-allocation_EQ)/((tokens-allocation_EQ)+(partnertokens-partnerallocation1))

gen exp_payoff_EQ= battle1value*p1_EQ + 3*battle2value*p2_EQ

//Column (3)
gen payoff_distance_EQ = exp_payoff - exp_payoff_EQ

forvalues c=1(1)7{
quietly: summ payoff_distance_EQ if tokens==200 & treatment==`c'
matrix Table7[`c',3] = round(r(mean),.001)
}

//Calculate best-response to other subject's actual play
gen allocation_BR = (((partnerallocation1*battle1value)^0.5)/((partnerallocation1*battle1value)^0.5+3*(battle2value*((partnertokens-partnerallocation1)/3))^0.5))*(tokens + partnertokens)- partnerallocation1
replace allocation_BR = 0.001 if allocation_BR == 0
replace allocation_BR = tokens - 0.001 if allocation_BR == tokens

//Calculate expected payoff associated to best response to other subject's actual play
gen p1_BR = allocation_BR/ (allocation_BR + partnerallocation1)
gen p2_BR = (tokens-allocation_BR)/((tokens-allocation_BR)+(partnertokens-partnerallocation1))

gen exp_payoff_BR= battle1value*p1_BR + 3*battle2value*p2_BR

//Column (4)
gen payoff_distance = exp_payoff - exp_payoff_BR

forvalues c=1(1)7{
quietly: summ payoff_distance if tokens==200 & treatment==`c'
matrix Table7[`c',4] = round(r(mean),.001)
}

matrix list Table7

*** Footnote 22 Anove test same average absolute value ***
oneway payoff_distance_eq treatment if tokens==200 & treatment<5, tabulate
oneway payoff_distance_OEQ treatment if tokens==200 & treatment<5, tabulate
oneway payoff_distance treatment if tokens==200 & treatment<5, tabulate
oneway payoff_distance_EQ treatment if tokens==200 & treatment<5, tabulate

restore

********************************************************************************
*********************************** Appendix ***********************************
********************************************************************************
//Table C1 Summary Statistics individual average allocation across locations
matrix TableC1 = J(49, 4, .)
matrix colnames TableC1 = "Far Left" "Left" "Right" "Far Right"
matrix rownames TableC1 = "IS" "N" "Mean" "std dev" "25 percent" "50 percent (median)" "75 percent" "IF" "N" "Mean" "std dev" "25 percent" "50 percent (median)" "75 percent" "IV" "N" "Mean" "std dev" "25 percent" "50 percent (median)" "75 percent" "IL" "N" "Mean" "std dev" "25 percent" "50 percent (median)" "75 percent" "AS" "N" "Mean" "std dev" "25 percent" "50 percent (median)" "75 percent" "AF" "N" "Mean" "std dev" "25 percent" "50 percent (median)" "75 percent" "AV" "N" "Mean" "std dev" "25 percent" "50 percent (median)" "75 percent"

preserve

//Create variable of allocation by position 
forvalues x=1/4{
	gen sloc`x'=0 						//sloc1 = Far Left ... sloc4 = Far Right
		forvalues y=1/4{
			replace sloc`x'=share`y' if battle`y'location==`x'
		}
}

collapse sloc1 sloc2 sloc3 sloc4 battle1location if tokens==200, by (id treatment)

forvalues x=1/4{
    forvalues y=1/7{
quietly: summ sloc`x' if treatment==`y', detail
matrix TableC1[(`y'-1)*7+2,`x'] = round(r(N),.001)
matrix TableC1[(`y'-1)*7+3,`x'] = round(r(mean),.001)
matrix TableC1[(`y'-1)*7+4,`x'] = round(r(sd),.001)
matrix TableC1[(`y'-1)*7+5,`x'] = round(r(p25),.001)
matrix TableC1[(`y'-1)*7+6,`x'] = round(r(p50),.001)
matrix TableC1[(`y'-1)*7+7,`x'] = round(r(p75),.001)
	}
}
restore

matrix list TableC1

//Figure D2: Marginal Effect of Allocation Share on Expected Payoff
preserve

//Calculate actual expected payoff
gen p1 = 1/2 if allocation1 + partnerallocation1 == 0
replace p1 = allocation1/ (allocation1 + partnerallocation1) if allocation1 + partnerallocation1 != 0
gen p2 = 1/2 if allocation1 + partnerallocation1 == tokens+partnertokens
replace p2 = (tokens-allocation1)/((tokens-allocation1)+(partnertokens-partnerallocation1)) if allocation1 + partnerallocation1 != tokens+partnertokens

gen exp_payoff= battle1value*p1 + 3*battle2value*p2

//
collapse exp_payoff share1 if tokens==200 & treatment<=4, by(treatment id)
reg exp_payoff i.treatment##c.share1##c.share1, robust
margins, at(treatment=(1(1)4) share1=(0(.05)0.6)) vsquish
marginsplot, xdimension(share1) legend(order(1 "IS" 2 "IF" 3 "IV" 4 "IL")) ytitle("Marginal Effect Expected Payoff") xtitle("Allocation Share") title("")

graph export exppay_ind.png, replace

restore