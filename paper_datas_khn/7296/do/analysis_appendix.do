
/***************************************************************************************
File:        analysis_appendix.do
Authors:     Priyoma Mustafi and Ritwik Banerjee
Paper:       Using social recognition to address the gender difference in volunteering 
             for low-promotability tasks
Last edit:   5/24/2025

Description: Take cleaned data, performs all analysis (tables) reported in appendix 
****************************************************************************************/


use "$replication/data/master.dta" , clear 

*--------------------------------------------------------------------*
* Fig A1(a) note: Test of significance- TotalInvestment (phase1data) *
*--------------------------------------------------------------------* 
preserve
   keep if period==1   & phase == 1
   forvalues i= 2(1)4 {
       ttest n_invest_subject , by(t`i'_t1) 
	   }
restore 
*--------------------------------------------------------------------*
* Fig A1(b) note: Test of significance- GroupInvestment (phase1data) *
*--------------------------------------------------------------------* 
preserve
    collapse group_success1 if period!=11 & phase==1, by(treatment phase session_id group period)
    egen unique_group = group(group period) 
	**** comparison with fic **********
	forvalues i=2(1)4 {
		
    gen t`i'_t1 = . 
	replace t`i'_t1 = 1 if treatment == `i'
	replace t`i'_t1 = 0 if treatment == 1 //fic
}
    bysort treatment: tabstat group_success1 if period!= 11 & phase==1 , stats(mean p50 n)

	forvalues i= 2(1)4 {
	   tab group_success1 t`i'_t1 if period!= 11 & phase==1 , chi2  exact 
	   }  
restore

*--------------------------------------------------------------------*
* Fig A2(a) note: Test of significance- TotalInvestment (phase2data) * 
*--------------------------------------------------------------------*
preserve
   keep if period==1    & phase == 2
   forvalues i= 2(1)5 {
       ttest n_invest_subject , by(t`i'_t1) 
	   }
restore 

*--------------------------------------------------------------------*
* Fig A2(b) note: Test of significance- GroupInvestment (phase1data) *
*--------------------------------------------------------------------*
preserve
    collapse group_success1 if period!=11 & phase==2, by(treatment phase session_id group period)
    egen unique_group = group(group period) 

	forvalues i=2(1)5 {
    gen t`i'_t1 = . 
	replace t`i'_t1 = 1 if treatment == `i'
	replace t`i'_t1 = 0 if treatment == 1 //fic
}
    bysort treatment: tabstat group_success1 if period!= 11 & phase==2 , stats(mean p50 n)

	forvalues i= 2(1)5 {
	   tab group_success1 t`i'_t1 if period!= 11 & phase==2 , chi2  exact 
	   }  
restore

*-----------------------------------------------------------*
* Table A3: Probit - Total and GroupInvestment (phase1data) *
*-----------------------------------------------------------*

/*TotalInvestment-Column 1-3*/
probit decision_1 t2 t3 t4   period if period!=11 & phase==1,  cluster (case_id)
mfx
outreg2 using "$replication/tables/TableA3.xls"  , replace mfx  addtext(Behavioral Controls , No , Demographic Controls , No )  bdec(3) sdec(2)  label nocons 
		 
probit decision_1 t2 t3 t4  period  non_conformity altruism agreeableness num_safe if period!=11 & phase==1, cluster (case_id)
mfx
outreg2 using "$replication/tables/TableA3.xls"  , append addtext(Behavioral Controls , Yes , Demographic Controls , No ) mfx  bdec(3) sdec(2) keep(t2 t3 t4  period)  label nocons 
		 
xi: probit decision_1 t2 t3 t4   period share_females_session non_conformity altruism agreeableness num_safe female age student i.religion i.caste i.fam_inc_category if period!=11 & phase==1, cluster (case_id)
mfx
outreg2 using "$replication/tables/TableA3.xls" , append addtext(Behavioral Controls , Yes , Demographic Controls , Yes ) keep(t2 t3 t4 period share_females_session) mfx  bdec(3) sdec(2)  label nocons 



/*GroupInvestment-Column 4-5*/
use "$replication/data/master.dta" , clear 
preserve 
    drop if period == 11
    collapse share_females_session , by ( treatment phase session_id )
	tempfile fem_share	
    save `fem_share' , replace
restore 

preserve
    collapse group_success1 if period!=11, by(treatment phase session_id group period session_id)
    egen unique_group = group(group period) 
    gen phase2 = 0 if phase == 1
	replace phase2 = 1 if phase == 2 
	label var phase2 "Phase 2"
	
	forvalues i=2(1)5 {
       gen t`i' = 0
       replace t`i' = 1 if treatment == `i'
	}
       label var t2 "Treatment Positve"
       label var t3 "Treatment Negative"
       label var t4 "Treatment PositiveNegative"
	   
	   merge m:1 phase treatment session_id  using `fem_share' , keepusing(share_females_session ) //merge==3
	   label var share_females_session "Female Session Share"

	   probit group_success1 t2 t3 t4  if period!=11 & phase==1,cluster(session_id)
	   mfx
	   outreg2 using "$replication/tables/TableA3.xls", append mfx addtext(Behavioral Controls , - , Demographic Controls , -)   bdec(3) sdec(2)  label nocons 
	   
	   probit group_success1 t2 t3 t4  period share_females_session if period!=11 & phase==1, cluster(session_id)
	   mfx
	   outreg2 using "$replication/tables/TableA3.xls", append mfx   addtext(Behavioral Controls , - , Demographic Controls , -)   bdec(3) sdec(2)  label nocons
	   
restore

*-----------------------------------------------------------*
* Table A4: Probit - Total and GroupInvestment (phase2data) *
*-----------------------------------------------------------*

/*TotalInvestment-Column 1-3*/
probit decision_1 t2 t3 t4  t5 period if period!=11 & phase==2,  cluster (case_id)
mfx
outreg2 using "$replication/tables/TableA4.xls"  , replace mfx  addtext(Behavioral Controls , No , Demographic Controls , No )  bdec(3) sdec(2)  label nocons 
		 
probit decision_1 t2 t3 t4 t5 period  non_conformity altruism agreeableness num_safe if period!=11 & phase==2, cluster (case_id)
mfx
outreg2 using "$replication/tables/TableA4.xls"  , append addtext(Behavioral Controls , Yes , Demographic Controls , No ) mfx  bdec(3) sdec(2) keep(t2 t3 t4 t5 period)  label nocons 
		 
xi: probit decision_1 t2 t3 t4  t5 period share_females_session non_conformity altruism agreeableness num_safe female age student i.religion i.caste i.fam_inc_category if period!=11 & phase==2, cluster (case_id)
mfx
outreg2 using "$replication/tables/TableA4.xls" , append addtext(Behavioral Controls , Yes , Demographic Controls , Yes ) keep(t2 t3 t4 t5 period share_females_session) mfx  bdec(3) sdec(2)  label nocons 



/*GroupInvestment-Column 4-5*/
use "$replication/data/master.dta" , clear 
preserve 
    drop if period == 11
    collapse share_females_session , by ( treatment phase session_id )
	tempfile fem_share	
    save `fem_share' , replace
restore 

preserve
    collapse group_success1 if period!=11, by(treatment phase session_id group period session_id)
    egen unique_group = group(group period) 
    gen phase2 = 0 if phase == 1
	replace phase2 = 1 if phase == 2 
	label var phase2 "Phase 2"
	
	forvalues i=2(1)5 {
       gen t`i' = 0
       replace t`i' = 1 if treatment == `i'
	}
       label var t2 "Treatment Positve"
       label var t3 "Treatment Negative"
       label var t4 "Treatment PositiveNegative"
       label var t5 "Treatment BaselineR"
	   
	   merge m:1 phase treatment session_id  using `fem_share' , keepusing(share_females_session ) //merge==3
	   label var share_females_session "Female Session Share"

		   
	   probit group_success1 t2 t3 t4 t5 if period!=11 & phase==2,cluster(session_id)
	   mfx
	   outreg2 using "$replication/tables/TableA4.xls", append mfx addtext(Behavioral Controls , - , Demographic Controls , -)   bdec(3) sdec(2)  label nocons 
	   
	   probit group_success1 t2 t3 t4 t5 period share_females_session if period!=11 & phase==2, cluster(session_id)
	   mfx
	   outreg2 using "$replication/tables/TableA4.xls", append mfx   addtext(Behavioral Controls , - , Demographic Controls , -)   bdec(3) sdec(2)  label nocons
	   
restore

*------------------------------------------------------------------------------*
* Table A5: Probit - Total and GroupInvestment wrt BaselineR 
* excluding Baseline (phase2data) 
*------------------------------------------------------------------------------*

/*TotalInvestment-Column 1-3*/
probit decision_1  t2 t3 t4 period if treatment !=1 & phase==2,  cluster (session_id)
mfx
outreg2 using "$replication/tables/TableA5.xls"  , replace mfx  addtext(Behavioral Controls , No , Demographic Controls , No )  bdec(3) sdec(2)  label nocons
		 
probit decision_1  t2 t3 t4 period non_conformity altruism agreeableness num_safe if treatment !=1 & phase==2, cluster (session_id)
mfx
outreg2 using "$replication/tables/TableA5.xls", append addtext(Behavioral Controls , Yes , Demographic Controls , No)  keep(t2 t3 t4 period share_females_session ) mfx  bdec(3) sdec(2)  label nocons
		 
xi: probit decision_1  t2 t3 t4 period share_females_session non_conformity altruism agreeableness num_safe female age student i.religion i.caste i.fam_inc_category if treatment !=1 & phase==2, cluster (session_id)
mfx
outreg2 using "$replication/tables/TableA5.xls", append addtext(Behavioral Controls , Yes , Demographic Controls , Yes ) keep(t2 t3 t4 period share_females_session ) mfx  bdec(3) sdec(2)  label nocons
		 
 
/*GroupInvestment-Column 4-5*/
use "$replication/data/master.dta" , clear 
preserve 
    drop if period == 11
    collapse share_females_session , by ( treatment phase session_id )
	tempfile fem_share	
    save `fem_share' , replace
restore 

preserve 
     
     collapse group_success1 if period!=11, by(treatment phase session_id group period session_id)
    egen unique_group = group(group period) 
    gen phase2 = 0 if phase == 1
	replace phase2 = 1 if phase == 2 
	label var phase2 "Phase 2"
	
	forvalues i=2(1)5 {
       gen t`i' = 0
       replace t`i' = 1 if treatment == `i'
	}
	
       label var t2 "Treatment Positve"
       label var t3 "Treatment Negative"
       label var t4 "Treatment PositiveNegative"
	   
     merge m:1 phase treatment session_id  using `fem_share' , keepusing(share_females_session ) //merge==3
	  label var share_females_session "Female Session Share"

		   
	 keep if phase== 2 // Comparing wrt Baseline R excluding Baseline
	 
	 probit group_success1 t2 t3 t4 if treatment != 1  ,cluster(session_id)
	   mfx
	   outreg2 using "$replication/tables/TableA5.xls", append  mfx  addtext(Behavioral Controls , - , Demographic Controls , -)   bdec(3) sdec(2)  label nocons
	   
	   probit group_success1  t2 t3 t4  period share_females_session if treatment != 1, cluster(session_id) 
	   mfx
	   outreg2 using "$replication/tables/TableA5.xls"  , append mfx    addtext(Behavioral Controls , - , Demographic Controls , -)   bdec(3) sdec(2)  label nocons
	   
restore

*-----------------------------------------------------------------------------------*
* Fig A3(a) note: Test of significance- TotalInvestment between gender (phase1data) *
*-----------------------------------------------------------------------------------*

preserve
   keep if period==1
   keep if phase==1
   forvalues i= 1(1)4 {
       ttest n_invest_subject if treatment==`i', by(female) 
	   }
restore 	

*-----------------------------------------------------------------------------------*
* Fig A3(b) note: Test of significance- TotalInvestment between gender (phase2data) *
*-----------------------------------------------------------------------------------*

preserve
   keep if period==1
   keep if phase==2
   forvalues i= 1(1)5 {
       ttest n_invest_subject if treatment==`i', by(female) 
	   }
restore 	

*-----------------------------------------------------*
* Table A6: Probit - Gender Differences (phase1data)  * 
*-----------------------------------------------------*

preserve 

     keep if period!= 11 & phase==1 
	 
	 levelsof treatment, local(levels) 
     capture outreg using "$replication/tables/TableA6.xls" ,replace addtitle(Probit: Gender Differences)
     foreach l of local levels {
	 
 	       probit decision_1 female period  if treatment  == `l' ,                                 cluster(case_id)
           mfx
           outreg2 using "$replication/tables/TableA6.xls" ,  mfx  addtext(Treatment , T`l' , Behavioral Controls , No , Demographic Controls , No ) bdec(3) sdec(2)   label nocons
		   
           probit decision_1 female period  non_conformity altruism agreeableness num_safe   if treatment  == `l', cluster (case_id)
           mfx
           outreg2 using "$replication/tables/TableA6.xls" , mfx  append  addtext(Treatment , T`l' , Behavioral Controls , Yes , Demographic Controls , No ) bdec(3) sdec(2) keep(female period)  label nocons
		   
		   xi : probit decision_1 female period share_females_session num_safe agreeableness altruism non_conformity  i.religion i.caste i.fam_inc_category age student  if treatment  == `l', cluster (case_id) 
           mfx
           outreg2 using "$replication/tables/TableA6.xls" , mfx  append  addtext(Treatment , T`l' , Behavioral Controls , Yes , Demographic Controls , Yes) keep(female period share_females_session ) bdec(3) sdec(2)  label nocons
		   		   
  }
  
restore 

*----------------------------------------------------*
* Table A7: Probit - Gender Differences (phase2data) * 
*----------------------------------------------------*

preserve 

     keep if period!= 11 & phase==2
	 
	 levelsof treatment, local(levels) 
     capture outreg using "$replication/tables/TableA7.xls" ,replace addtitle(Probit: Gender Differences)
     foreach l of local levels {
	 
 	  probit decision_1 female period  if treatment  == `l' , cluster(case_id)
           mfx
           outreg2 using "$replication/tables/TableA7.xls" ,  mfx  addtext(Treatment , T`l' , Behavioral Controls , No , Demographic Controls , No ) bdec(3) sdec(2)  label nocons
		   
           probit decision_1 female period  non_conformity altruism agreeableness num_safe   if treatment  == `l', cluster (case_id)
           mfx
           outreg2 using "$replication/tables/TableA7.xls" , mfx  append  addtext(Treatment , T`l' , Behavioral Controls , Yes , Demographic Controls , No ) bdec(3) sdec(2) keep(female period)  label nocons
		   
		   xi : probit decision_1 female period share_females_session num_safe agreeableness altruism non_conformity  i.religion i.caste i.fam_inc_category age student  if treatment  == `l', cluster (case_id)
           mfx
           outreg2 using "$replication/tables/TableA7.xls" , mfx  append  addtext(Treatment , T`l' , Behavioral Controls , Yes , Demographic Controls , Yes) keep(female period share_females_session ) bdec(3) sdec(2)  label nocons
		   		   
  }
  
restore 

*-------------------------------------------------------------------*
* Table A8: Probit-Gender Differences excluding fem share (alldata) *    
*-------------------------------------------------------------------*

preserve 
     keep if period!= 11  
	 
	 levelsof treatment, local(levels) 
     capture outreg using "$replication/tables/TableA8.xls" ,replace addtitle(Probit: Gender Differences excluding fem share)
     foreach l of local levels {
	 
		    xi : probit decision_1 female period phase2 num_safe agreeableness altruism non_conformity  i.religion i.caste i.fam_inc_category age student  if treatment  == `l', cluster (case_id)
           mfx
           outreg2 using "$replication/tables/TableA8.xls" , mfx  append  addtext(Treatment , T`l' , Behavioral Controls , Yes , Demographic Controls , Yes , Session FE , No) keep(female period phase2) bdec(3) sdec(2)  label nocons
  
  }
  
restore 

*-------------------------------------------------------------------*
* Table A9: Probability of Investment and Competitiveness (alldata) *   
*-------------------------------------------------------------------*

**Baseline
reg decision_1 comp_scale female period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if treatment == 1 & period!=11, cluster(case_id) 
outreg2 using "$replication/tables/TableA9.xls", replace addtext(Behavioral Controls , Yes , Demographic Controls , Yes , Treatment, Baseline) keep(comp_scale female period phase2 share_females_session ) bdec(3) sdec(2) label nocons

**Positive
reg decision_1 comp_scale female period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if treatment == 2 & period!=11, cluster(case_id)
outreg2 using "$replication/tables/TableA9.xls",  append addtext(Behavioral Controls , Yes , Demographic Controls , Yes , Treatment, Positive) keep(comp_scale female period phase2 share_females_session ) bdec(3) sdec(2) label nocons

**Negative
reg decision_1 comp_scale female period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if treatment == 3 & period!=11, cluster(case_id)
outreg2 using "$replication/tables/TableA9.xls",  append addtext(Behavioral Controls , Yes , Demographic Controls , Yes , Treatment, Negative) keep(comp_scale female period phase2 share_females_session )bdec(3) sdec(2) label nocons

**PositiveNegative
reg decision_1 comp_scale female period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if treatment == 4 & period!=11, cluster(case_id)
outreg2 using "$replication/tables/TableA9.xls",   append addtext(Behavioral Controls , Yes , Demographic Controls , Yes , Treatment, PositiveNegative) keep(comp_scale female period phase2 share_females_session ) bdec(3) sdec(2) label nocons

**Baseline-R
reg decision_1 comp_scale female period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if treatment == 5 & period!=11 , cluster(case_id)
outreg2 using "$replication/tables/TableA9.xls",   append addtext(Behavioral Controls , Yes , Demographic Controls , Yes , Treatment, Baseline-R) keep(comp_scale female period phase2 share_females_session ) bdec(3) sdec(2) label nocons

**all SR
reg decision_1 comp_scale female period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if treatment != 1 & period!=11, cluster(case_id)
outreg2 using "$replication/tables/TableA9.xls",   append addtext(Behavioral Controls , Yes , Demographic Controls , Yes , Treatment, AT) keep(comp_scale female period phase2 share_females_session ) bdec(3) sdec(2) label nocons

****************************
*beta comparisons - last row*
****************************

reg decision_1 comp_scale female period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if treatment == 1 & period != 11
estimate store h2 

reg decision_1 comp_scale female period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if treatment == 2 & period != 11
estimate store h3

reg decision_1 comp_scale female period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if treatment == 3 & period != 11
estimate store h4

reg decision_1 comp_scale female period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if treatment == 4 & period != 11
estimate store h5

reg decision_1 comp_scale female period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if treatment == 5 & period != 11
estimate store h6

reg decision_1 comp_scale female period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if treatment !=1 & period != 11
estimate store h7

suest * , vce(cluster case_id) 
test [h2_mean]comp_scale = [h3_mean]comp_scale //0.2896 ~ 0.29
test [h2_mean]comp_scale = [h4_mean]comp_scale // 0.2655 ~ 0.27
test [h2_mean]comp_scale = [h5_mean]comp_scale //0.2279 ~ 0.23
test [h2_mean]comp_scale = [h6_mean]comp_scale //0.0678 ~ 0.07
test [h2_mean]comp_scale = [h7_mean]comp_scale //0.1015 ~0.10

*----------------------------------------------------------------------------*
* Table A10: Comparing within gender wrt Baseline R 
* excluding Baseline (phase2data)     
*----------------------------------------------------------------------------*

label var t2_t5 "Treatment Positve"
label var t3_t5 "Treatment Negative"
label var t4_t5 "Treatment PositiveNegative"

* Female only

xi: probit decision_1 t2_t5 period share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if female==1 & phase==2, cluster (session_id) 
mfx
outreg2 using "$replication/tables/TableA10.xls", replace addtext(Behavioral Controls , Yes , Demographic Controls , Yes ,  Sample, Females) keep(t2_t5 period share_females_session) mfx bdec(3) sdec(2)  label nocons 
		 
xi: probit decision_1 t3_t5 period  share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if female==1  & phase==2, cluster (session_id) 
mfx
outreg2 using "$replication/tables/TableA10.xls", append addtext(Behavioral Controls , Yes , Demographic Controls , Yes ,  Sample, Females) keep(t3_t5 period share_females_session) mfx bdec(3) sdec(2)  label nocons 

xi: probit decision_1 t4_t5 period  share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if female==1  & phase==2, cluster (session_id) 
mfx
outreg2 using "$replication/tables/TableA10.xls", append addtext(Behavioral Controls , Yes , Demographic Controls , Yes ,   Sample, Females) keep(t4_t5 period share_females_session) mfx bdec(3) sdec(2)  label nocons 


* Male only

xi: probit decision_1 t2_t5 period share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if female==0  & phase==2, cluster (session_id) 
mfx
outreg2 using "$replication/tables/TableA10.xls", append addtext(Behavioral Controls , Yes , Demographic Controls , Yes , Sample, Males) keep(t2_t5 period share_females_session) mfx bdec(3) sdec(2)  label nocons 
		 
xi: probit decision_1 t3_t5 period  share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if female==0  & phase==2, cluster (session_id) 
mfx
outreg2 using "$replication/tables/TableA10.xls", append addtext(Behavioral Controls , Yes , Demographic Controls , Yes, Sample, Males) keep(t3_t5 period share_females_session) mfx bdec(3) sdec(2)  label nocons 

xi: probit decision_1 t4_t5 period  share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if female==0  & phase==2, cluster (session_id) 
mfx
outreg2 using "$replication/tables/TableA10.xls", append addtext(Behavioral Controls , Yes , Demographic Controls , Yes , Sample, Males) keep(t4_t5 period share_females_session) mfx bdec(3) sdec(2)  label nocons 

*------------------------------------------------------------*
* Table A11: Effect of Treatment on the Gender Gap (alldata) *   
*------------------------------------------------------------*

label variable t2_t1 "Treatment Positive"
label variable t3_t1 "Treatment Negative"
label variable t4_t1 "Treatment PositiveNegative"
label variable t5_t1 "Treatment BaselineR"

reg decision_1 female t2_t1 femXt2 period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if t2_t1!=., cluster (session_id)
outreg2 using "$replication/tables/TableA11.xls" , replace addtext(Behavioral Controls , Yes , Demographic Controls , Yes ) keep(female t2_t1 femXt2 period phase2 share_females_session) bdec(3) sdec(2) label nocons 

reg decision_1 female t3_t1 femXt3 period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if t3_t1!=., cluster (session_id)
outreg2 using "$replication/tables/TableA11.xls" , append addtext(Behavioral Controls , Yes , Demographic Controls , Yes) keep(female t3_t1 femXt3 period phase2 share_females_session) bdec(3) sdec(2) label nocons 

reg decision_1 female t4_t1 femXt4 period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if t4_t1!=., cluster (session_id)
outreg2 using "$replication/tables/TableA11.xls" , append addtext(Behavioral Controls , Yes , Demographic Controls , Yes ) keep(female t4_t1 femXt4 period phase2 share_females_session) bdec(3) sdec(2) label nocons 

reg decision_1 female t5_t1 femXt5 period share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if t5_t1!=., cluster (session_id) 
outreg2 using "$replication/tables/TableA11.xls" , append addtext(Behavioral Controls , Yes , Demographic Controls , Yes) keep(female t5_t1 femXt5 period share_females_session) bdec(3) sdec(2) label nocons 