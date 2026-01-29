/**********************************************************************************************
File:        cleaning.do
Authors:     Priyoma Mustafi and Ritwik Banerjee
Paper:       Using social recognition to address the gender difference in volunteering 
             for low-promotability tasks
Last edit:   5/22/2025

Description: Take phase 1 & phase 2 exprimental data to cleans Period 11 (questionnaire) data, 
             create necessary vars for analysis. All variables are appropiately labelled. 
***********************************************************************************************/


*---------------------------------------*
preserve
  import delimited "$replication/raw/phase1.csv" , varnames(1) clear
  gen phase=1
  rename v73 RN1
  rename v74 RN2
  tempfile phase1	
  save `phase1' , replace
restore

preserve
  import delimited "$replication/raw/phase2.csv" ,  varnames(1) clear
  gen phase=2
  rename v81 RN1
  rename v82 RN2
  tempfile phase2	
  save `phase2' , replace
restore

use `phase1'  , clear
append using `phase2' ,  force


gen phase2 = 0 if phase == 1
replace phase2 = 1 if phase == 2

sort  treatment phase session_no subject period
egen case_id = group( treatment phase session_no subject)
egen session_id = group ( treatment phase session_no) 

label  define treat 1 "Baseline" 2 "Positive" 3 "Negative" 4 "Pos_Neg" 5 "BaselineR", replace 
label values treatment treat

label var phase "Data Wave"
label var session_id "sessionID"
label var case_id "Unique SubjectID"
label var id "SubjectID within phase data"
label var session_no "SessionID within phase data"
label var subject "SubjectID within Session"
label var period "Round"
label var treatment "Treatment Label"
label var group "GroupID, groups of 3"

save  "$replication/data/all_data.dta" , replace 

order phase treatment session_id period group subject case_id  decision_1 earnings_1
sort phase treatment session_id subject period  


*--------------------------------------*
* Drop Unneccesary ztree generated Vars
*--------------------------------------*
drop global_period participate totalprofit profit subjects 

*---------------------------------------------------------------------*
* Drop Unneccesary various random numbers created in ztree programming
*---------------------------------------------------------------------*
drop RN1 RN2 rn1 rn2 random_no0 random_no1 rand

*----------------------*
* Risk: HoltLaury Vars *
*----------------------* 
destring a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 decision choice, replace force
//ztree has 0 for the first time the variable is defined if no one answered this question then
foreach var of varlist a1 a2 a3 a4 a5 a6 a7 a8 a9 a10  decision {
	replace `var' =. if period==1 & `var'!=.
}
label define HL 0 "risky" 1 "safe"  // B vs A 
label values a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 choice HL

egen num_safe = rowtotal(a1 a2 a3 a4 a5 a6 a7 a8 a9 a10) if period == 11

rename decision chosen_decisionHL
rename choice chosen_choiceHL 


*---------------------------------------------*
* Carry upward period 11 vars (questionnaire)*
*---------------------------------------------*
gen female = gender
drop gender
replace female = . if female == 0 //ztree has 0 for the first time the variable is defined if no one answered this question then
bysort case_id (female): replace female =female[_n-1] if female == .
replace female = 0 if female == 1
replace female = 1 if female == 2
label define fem_label 0 "Male" 1 "Female" 
label values female fem_label
 
sort phase treatment session_id subject period  

replace decision_1 = . if period == 11 //no investment decision in period 11

foreach x in friends family fb  taste_friends argue_friends defend_unpopular less_fortunate themselves community finds_fault cold_aloof considerate_kind cooperate rude helpful_unselfish quarrels forgiving trusting stress risks { 
      replace `x' = . if `x' == 0
	  bysort case_id (`x'): replace `x' =`x'[_n-1] if `x' == .
}

foreach x in caste age religion marks10 marks12 student major fam_inc { 
      replace `x' = . if `x' == 0
	  bysort case_id (`x'): replace `x' =`x'[_n-1] if `x' == .
}

bysort case_id (num_safe) : replace num_safe = num_safe[_n-1] if num_safe == . 


**phase2 new vars- competition
destring count_friends  comp_scale nv_choice, replace force
foreach x in count_friends  comp_scale nv_choice  { 
      replace `x' = . if `x' == 0 //ztree has 0 for the first time the variable is defined 
	  bysort case_id (`x'): replace `x' =`x'[_n-1] if `x' == . & phase == 2
}

sort phase treatment session_id subject period  

*--------------*
* Demographics *
*--------------*
label define major_label  1 "Arts" 2 "Business"  3 "Engineering" 4 "Natural Sciences" 5 "Humanities-Social Sciences" 6 "Physical Sciences" 7 "Physical Sciences"
label values major major_label  
 
label define collegeyears_label 1 "1st" 2 "2nd" 3 "3rd" 4 "4th" 5 "5th"
label values student collegeyears_label

label define caste_label 1 "General" 2 "SC" 3 "ST" 4 "OBC" 5 "Prefer not to say"
label values caste caste_label

label define religion_label 1 "Hindu" 2 "Muslim" 3 "Christian" 4 "Prefer not to say"
label values religion religion_label

//clean bad data: correcting class 10 & 12 marks: 2 individuals have given GPA//
replace marks10 = marks10*10 if marks10 <10 & phase==2 
replace marks12 = marks12*10 if marks12 < 10 & phase==2 
replace marks10 = marks10*10 if marks10 == 9.5 
replace marks12 = marks12*10 if marks12 == 5 


//clean bad data: family income categories// 
replace fam_inc = 200000 if ( fam_inc <= 400 ) & phase==2 
replace fam_inc = 50000 if ( fam_inc == . & phase==1) 

gen fam_inc_category = 0
replace fam_inc_category = 1 if fam_inc <= 300000/12 //EWS
replace fam_inc_category = 2 if (fam_inc > 300000/12 & fam_inc <= 600000/12) // LIG
replace fam_inc_category = 3 if (fam_inc > 600000/12 & fam_inc <= 1200000/12) //MIG
replace fam_inc_category = 4 if (fam_inc > 1200000/12 & fam_inc <= 1800000/12) //HIG
replace fam_inc_category = 5 if (fam_inc > 1800000/12 & fam_inc <= 10000000/12) //Rich
replace fam_inc_category = 6 if fam_inc > 10000000/12 //Super rich

label define faminc_label 1 "EWS" 2 "LIG" 3 "MIG" 4 "HIG" 5 "Rich" 6 "Super-Rich"
label values fam_inc_category faminc_label
label var fam_inc_category "Family Income"


*------------------------------------------------------------*
* Survey measures of preferences and personality attributes  *
*------------------------------------------------------------*
gen finds_fault_rev=6-finds_fault

gen cold_aloof_rev=6-cold_aloof

gen rude_rev=6-rude

gen quarrels_rev=6-quarrels

gen agreeableness=(finds_fault_rev + cold_aloof_rev + considerate_kind + cooperate+rude_rev + helpful_unselfish + quarrels_rev + forgiving + trusting)/9

gen themselves_rev=6-themselves

gen altruism=(less_fortunate + themselves_rev + community)/3

gen non_conformity=(taste_friends + argue_friends + defend_unpopular)/3

*---------------------*
* Comprehension Quiz  *
*---------------------*
destring ans1 ans3a ans4a ans5a ans6 ans7, replace force 
label define yn 1 "Yes" 0 "No"
label define  q_pay 0 "NOTA" 100 "100" 300 "300" 900 "900"
label define q_round  1  "All the rounds" 2  "Random one round b/w Round 1 and 10 plus Round 11" 3 "First round only" 4 " Last round only" 
label define q_time 1  "45 secs" 2  "90 secs" 3 "b/w 45-90 secs"  0  "NOTA"

label values ans1 yn
foreach var of varlist ans3a ans4a ans5a {
	label values `var' q_pay 
}

label values ans6 q_round
label values ans7 q_time
 
*--------------------------*
* Create Vars for Analysis *
*--------------------------*
**number of times invested in 10 rounds
  bysort case_id: egen n_invest_subject=total(decision_1) if period! = 11
 
*dummy vars for each treatment
forvalues i=1(1)5 {
       gen t`i' = 0
       replace t`i' = 1 if treatment == `i'
} 

label variable t1 "Treatment Baseline"
label variable t2 "Treatment Positve"
label variable t3 "Treatment Negative"
label variable t4 "Treatment PositiveNegative"
label variable t5 "Treatment BaselineR"

**dummy do pairwise comparisons to baseline

  forvalues i=2(1)5 {
    gen t`i'_t1 = . 
	replace t`i'_t1 = 1 if treatment == `i'
	replace t`i'_t1 = 0 if treatment == 1 //fic
}

label define vs_pos 0 "Baseline" 1 "Positive", replace
label values t2_t1 vs_pos
label define vs_neg 0 "Baseline" 1 "Negative" , replace
label values t3_t1 vs_neg
label define vs_pos_neg 0 "Baseline" 1 "Pos_Neg" , replace
label values t4_t1 vs_pos_neg
label define vs_onlyname 0 "Baseline" 1 "BaselineR" , replace
label values t5_t1 vs_onlyname

label variable t2_t1 "Positive vs Baseline (omitted)"
label variable t3_t1 "Negative vs Baseline (omitted)"
label variable t4_t1 "PositiveNegative vs Baseline (omitted)"
label variable t5_t1 "BaselineR vs Baseline (omitted)"

*dummy interaction with female

g femXt2=t2_t1*female
g femXt3=t3_t1*female 
g femXt4=t4_t1*female 
g femXt5=t5_t1*female 

label variable femXt2 "Treatment Positive X Female"
label variable femXt3 "Treatment Negative X Female"
label variable femXt4 "Treatment PositiveNegative X Female"
label variable femXt5 "Treatment BaselineR X Female"

**dummy do pairwise comparisons to baselineR

forvalues i=1(1)4 {
    gen t`i'_t5 = . 
	replace t`i'_t5 = 1 if treatment == `i'
	replace t`i'_t5 = 0 if treatment == 5 //only name
}

label define vs_fic1 0 "BaselineR" 1 "Baseline", replace
label values t1_t5 vs_fic1
label define vs_pos1 0 "BaselineR" 1 "Positive", replace
label values t2_t5 vs_pos1
label define vs_neg1 0 "BaselineR" 1 "Negative" , replace
label values t3_t5 vs_neg1
label define vs_pos_neg1 0 "BaselineR" 1 "Pos_Neg" , replace
label values t4_t5 vs_pos_neg1

label variable t1_t5 "Baseline vs BaselineR (omitted)"
label variable t2_t5 "Positive vs BaselineR (omitted)"
label variable t3_t5 "Negative vs BaselineR (omitted)"
label variable t4_t5 "PositiveNegative vs BaselineR (omitted)"

**session share female 
bysort treatment session_id period  : egen session_size = max(subject)
bysort treatment session_id period : egen num_fem_session = total(female)
bysort treatment session_id period group  : egen num_fem_group = total(female)
gen share_females_session = num_fem_session/session_size
gen share_females_group = num_fem_group/3
replace num_fem_group = . if period == 11 //no groups in HL
replace share_females_group = . if period == 11 //no groups in HL

**count vars
gen byte tag = 1
bysort treatment session_id (tag): gen byte uniq_tag = (_n == 1)
egen num_session_treat = total(uniq_tag), by(treatment)
egen num_session_phase = total(uniq_tag), by(treatment phase)
drop tag uniq_tag

gen byte tag = 1
bysort treatment session_id case_id (tag): gen byte uniq_tag = (_n == 1)
egen num_subject_treat = total(uniq_tag), by(treatment)
egen num_subject_phase = total(uniq_tag), by(treatment phase)
drop tag uniq_tag

*-----------------*
* Label Variables *
*-----------------*

**identifiers
label var phase2 "Phase 2"
label var subject "SubjectID within Session"
label var period "Round"
label var treatment "Treatment Label"
label var group "GroupID, groups of 3"
label var phase "Data Wave"
label var session_id "sessionID"
label var case_id "Unique SubjectID"
label var female "Female"

**quiz
label variable ans1 "Will you play with the same group members in every round? "
label variable ans3a "Suppose in a round, you do not invest but someone else invests. How much do you earn? "
label variable ans4a "Suppose in a round, you invest before anyone else. How much do you earn? "
label variable ans5a "Suppose in a round, no one from your group invests. How much do you earn? "
label variable ans6 "Which round will you be paid for?"
label variable ans7 "How much time do you have to decide?"

**label investment decision
label var decision_0 "Practice Round: Invest"
label var decision_1 "Main Rounds: Investment Decision"
label variable n_invest_subject "Num of times one invests in 10 periods"
label variable group_success1 "Main Rounds: Group Investment" 
label var earnings_1 "Main Rounds: Investment Payoff"

**competion 
label define nv 1 "Piece Rate" 2 "Tournament Entry" , replace 
label values nv_choice nv
label var comp_scale "Competitiveness"

**holt laury risk game
foreach v of varlist a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 {
	label var `v' "HL Decision `v': Ans A or B"
}
label var chosen_decisionHL "Chosen Decision for HL"
label var chosen_choiceHL "Option A/B Chosen for HL"
label var payoff_hl "HL payoff"
label var num_safe "Num safe options chosen in HL"

**random periods
label var randomperiod1 "Chosen period 1-10"
label var randomperiod2 "Chosen period 11"

**payoffs
label var finalpayoff "Chosen Invest+HL payoff"
label var finalpayoff1  "Chosen Invest payoff"
label var finalpayoff2 "Chosen HL payoff"

**femal shares**
label variable session_size "Num Subjects in Session"
label variable num_fem_session "Num Females in Session"
label variable num_fem_group "Num Females in Group"
label variable share_females_session "Female Session Share"
label variable share_females_group "Share of Females in Group"

**fictitious name chosen**
label var gender_ans "Intro screen gender ans"
label var gender_chosen "Gender of fictitious name"

**recognition**
label variable volunteerid_1 "Subject ID of volunteer"

**count vars
label var num_session_treat "Num of Sessions, by treat"
label var num_session_phase  "Num of Sessions, by treat & phase"
label var num_subject_treat "Num of Subjects, by treat"
label var num_subject_phase  "Num of Subjects, by treat & phase"

**timeout trial period
forvalues i=1(1)10{
		label var time0_group`i' "Trial Period: Timeout for Group `i'"
	}

**timeout main period
forvalues i=1(1)10{
		label var time1_group`i' "Main Periods: Timeout for Group `i'"
	}

**timeout
label variable time0 "Practice Round: time alloted b/w 45-90sec"
label variable time1 "Main Rounds: Time alloted b/w 45-90sec"

sort phase treatment session_id subject period  
order phase treatment session_id period group subject case_id female decision_1 n_invest_subject


save  "$replication/data/master.dta" , replace
