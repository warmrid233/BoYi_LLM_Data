cap log close
log using analysis, text replace
set more off
set scheme s1mono, permanent
clear

/*
	Importing the data and defining some treatment indicators. 
*/
use data/mmex_situations, clear
gen byte d = 0 if decision=="NO"
replace  d = 1 if decision=="EXIT"
replace  d = 2 if decision=="ENTRY"
label define d 0 "0:no" 1 "1:exit" 2 "2:entry"
label values d d
gen byte information = inlist(treatment, "T1","T2","T3")
label define information 0 "no information" 1 "information"
label values information information
label var information "information"

encode treatment, gen(TREAT)
label define TREAT 1 "Student - not-working, complete info" ///
	2 "Student - not-working, no info" ///
	3 "Student - working, complete info" ///
	4 "Student - working, no info" ///
	5 "Client - needy, complete info" ///
	6 "Client - needy, no info", replace
label values TREAT TREAT
gen     receiver = 1 if inlist(treatment,"T1","T1*")
replace receiver = 2 if inlist(treatment,"T2","T2*")
replace receiver = 3 if inlist(treatment,"T3","T3*")

label define receiver 1 "Student - not working" 2 "Student - working" 3 "Client-needy"
label values receiver receiver

gen given1share = given1/200
label var given1share "Share given"

/*
	Table 1 (section 1).
*/
tab receiver information

/*
	Descriptives of sample in previous year (section 1)
*/
gen female  = (sex==2)
tabstat age kull female 
tab charity
tab election, missing

/*
	Table 2 (section 2).
*/
table receiver information, c(mean given1share semean given1share) row f("%4.3f")
/*
	Figure 2 (section 2).
	Re-ordering 
*/
recode TREAT (1 = 102) (2 = 101) (3 = 104) (4 = 103) (5 = 106) (6 = 105), gen(TREAT_R)
label define  TREAT_R 101 "Student - not-working, no info" 102 "Student - not-working, complete info"
label define TREAT_R 103 "Student - working, no info" , add
label define TREAT_R 104 "Student - working, complete info", add
label define TREAT_R 105 "Client - needy, no info", add
label define TREAT_R 106 "Client - needy, complete info", add
label values TREAT_R TREAT_R
hist given1share , xlabel(0(0.25)1) by(TREAT_R, col(2) note("")  style("combine"))  saving(hist,replace) start(0) w(0.090909091) frac 
graph export hist.eps, replace
! epstopdf hist.eps
/*
	Keeping everything, equal splits, giving everything (reported in text, section 2).
*/
gen byte keeping_everything = (given1==0)
table receiver information, c(mean keeping_everything) format("%4.3f")
gen byte equal_split = (given1==100)
table receiver information, c(mean equal_split) format("%4.3f")
gen byte giving_everything = (given1==200)
table receiver information, c(mean giving_everything) format("%4.3f")


/*
	Table 3 (section 3). 
*/
gen byte Moral = inlist(receiver,2,3)
gen byte charitable = charity>=2
gen byte rodgronn = inlist(election,1,2,3)
gen MxI = Moral * information
global background "charitable rodgronn female age kull"

label var MxI "Moral $\times$ Information"
label var charitable "Charity"
label var rodgronn "Left-wing"
label var female "Female"
label var age "Age"
label var kull "Business education"
reg given1share Moral
est store m1
reg given1share information 
est store m2
reg given1share Moral information MxI 
est store m3
lincom information + MxI
reg given1share Moral information MxI ${background} 
est store m4
lincom information + MxI
reg given1share Moral ${background} if information==0 
est store m5
reg given1share Moral ${background} if information==1 
est store m6
esttab m1 m2 m3 m4 m5 m6, b(2) se(2) star(* 0.1 **  0.05 *** 0.01) r2 ///
        compress order(Moral information MxI ${background}) label
esttab m1 m2 m3 m4 m5 m6 using maintable.tex, b(2) se(2) star(* 0.1 **  0.05 *** 0.01) r2 ///
        compress order(Moral information MxI ${background}) label booktabs replace

/*
	Table 4 (section 4).
*/
gen opting_out = (d==1)
gen opting_in  = (d==2)
table receiver if information==1, c(mean opting_out semean opting_out) row format("%4.3f")
table receiver if information==0, c(mean opting_in semean opting_in) row format("%4.3f")


/*
	Table 5 (section 4).
*/
// First left panel (default no info).
table receiver d if information==0, c(mean given1share semean given1share) format("%4.3f")
// Then right panel:
table receiver d if information==1, c(mean given1share semean given1share) format("%4.3f")

/*
	Tests in text in Section 4.
*/
tab d if given1!=given2
// Opting out.
ttest given1share if information==1, by(opting_out)
ranksum given1share if information==1, by(opting_out)
// Opting in.
ttest given1share if information==0, by(opting_in)
ranksum given1share if information==0, by(opting_in)
// Given entry/exit, what are the changes in amount?
gen final = given1
replace final = given2 if given2<.
gen final_share = final/200
table d, c(mean given1share mean final_share) f("%4.3f")
// Those that make changes.
gen byte make_changes = given1!=given2 & given2<.
table d if make_changes==1, c(mean given1share mean final_share n make_changes) f("%4.3f")
// Information treatment: How many change a positive share to zero when switching information:
tab keeping_everything information
list given1 given2 information if make_changes==1 & given2==0



/*
	Table A1. Regression analysis with separate dummies for the moral treatments.
*/
tab receiver, gen(R)
gen info_R2 = information*R2
gen info_R3 = information*R3

label var R2 "Student - working"
label var R3 "Client - needy"
label var info_R2 "Student - working $\times$ info"
label var info_R3 "Client - needy $\times$ info"

reg given1share R2 R3
est store m1r 
reg given1share information
est store m2r
reg given1share R2 R3 information info_R2 info_R3 
est store m3r
reg given1share R2 R3 information info_R2 info_R3 ${background} 
est store m4r
reg given1share R2 R3 ${background} if information==0 
est store m5r
reg given1share R2 R3 ${background} if information==1 
est store m6r
esttab m1r m2r m3r m4r m5r m6r, b(2) se(2) r2  star(* 0.1 ** 0.05 *** 0.01) label ///
	order(R2 R3 information info_R2 info_R3 ${background})
esttab m1r m2r m3r m4r m5r m6r using maintable_r.tex, b(2) se(2) r2  star(* 0.1 ** 0.05 *** 0.01) label ///
	order(R2 R3 information info_R2 info_R3 ${background}) booktabs replace 

/*
	Table A2. Statistical tests, no information vs information.
*/
forvalues t=1/3 {
	di "receiver: `t'"
	ttest given1share if receiver==`t', by(information)
	ranksum given1share if receiver==`t', by(information)
}


/*
	Table A3. Different moral treatments.
	Putting t-values in matrix A.
	Inconvenience: Stata's ranksum command doesn't save p-value. Must 
	calculate manually to populate A.
*/
mat define A = J(3,4,-99)
ttest given1share if information==0 & inlist(receiver,1,2), by(receiver) 
mat A[1,1] = r(p)
ranksum given1share if information==0 & inlist(receiver,1,2), by(receiver)
mat A[1,2] =2*(1-normprob(abs(r(z))))
ttest given1share if information==0 & inlist(receiver,1,3), by(receiver) 
mat A[2,1] = r(p)
ranksum given1share if information==0 & inlist(receiver,1,3), by(receiver)
mat A[2,2] = 2*(1-normprob(abs(r(z))))
ttest given1share if information==0 & inlist(receiver,2,3), by(receiver) 
mat A[3,1] = r(p)
ranksum given1share if information==0 & inlist(receiver,2,3), by(receiver)
mat A[3,2] =2*(1-normprob(abs(r(z))))
ttest given1share if information==1 & inlist(receiver,1,2), by(receiver) 
mat A[1,3] = r(p)
ranksum given1share if information==1 & inlist(receiver,1,2), by(receiver)
mat A[1,4] =2*(1-normprob(abs(r(z))))
ttest given1share if information==1 & inlist(receiver,1,3), by(receiver) 
mat A[2,3] = r(p)
ranksum given1share if information==1 & inlist(receiver,1,3), by(receiver)
mat A[2,4] = 2*(1-normprob(abs(r(z))))
ttest given1share if information==1 & inlist(receiver,2,3), by(receiver) 
mat A[3,3] = r(p)
ranksum given1share if information==1 & inlist(receiver,2,3), by(receiver)
mat A[3,4] =2*(1-normprob(abs(r(z))))
mat list A, format("%4.3f")


/* 
	Table A4. Treatment differences, hypothetical responses.
	
	The information header is still for the default information.
*/
gen hypo_change = (given_hypo - given1)/200
table receiver information, c(mean hypo_change semean hypo_change) row f("%4.3f")
