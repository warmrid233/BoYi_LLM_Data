/**************************************************************************************
File:         analysis_main.do
Authors:      Priyoma Mustafi and Ritwik Banerjee
Paper:        Using social recognition to address the gender difference in volunteering 
              for low-promotability tasks
Last edit:    5/24/2025

Description:  Take cleaned data, performs all analysis (tables, statistical tests) 
              reported in main paper 
****************************************************************************************
*/


use "$replication/data/master.dta" , clear 
	
*------------------------------------------------------------------*
*  Fig 1(a) note: Test of significance- TotalInvestment (fulldata) *
*------------------------------------------------------------------*

preserve
   keep if period==1
   forvalues i= 2(1)5 {
       ttest n_invest_subject , by(t`i'_t1) 
	   }
restore 

*-----------------------------------------------------------------*
* Fig 1(b) note: Test of significance- GroupInvestment (fulldata) * 
*-----------------------------------------------------------------*

preserve
    collapse group_success1 if period!=11, by(treatment phase session_id group period)
    egen unique_group = group(group period) 
	forvalues i=2(1)5 {
    gen t`i'_t1 = . 
	replace t`i'_t1 = 1 if treatment == `i'
	replace t`i'_t1 = 0 if treatment == 1 //fic
}
    bysort treatment: tabstat group_success1 if period!= 11 , stats(mean p50 n)

	forvalues i= 2(1)5 {
	   tab group_success1 t`i'_t1 if period!= 11 , chi2  exact 
	   }  
	   
	   /* Page 14:Test of significance- different from Mixed nash eq (fulldata) */ 
	   
	ttest group_success1 = 0.54 if treatment == 1
    ttest group_success1 = 0.64 if treatment == 1
    ttest group_success1 = 1 if treatment == 1

restore

*--------------------------------------------------------*
* Table 2: Probit - Total and GroupInvestment (fulldata) * 
*--------------------------------------------------------*

/*TotalInvestment-Column 1-3*/
probit decision_1 t2 t3 t4 t5 phase2 period if period != 11,  cluster (session_id)
mfx
outreg2 using "$replication/tables/Table2.xls"  , replace mfx  addtext(Behavioral Controls , No , Demographic Controls , No )  bdec(3) sdec(2)  label nocons 
		 
probit decision_1 t2 t3 t4 t5 phase2 period  non_conformity altruism agreeableness num_safe if period != 11, cluster (session_id)
mfx
outreg2 using "$replication/tables/Table2.xls"  , append addtext(Behavioral Controls , Yes , Demographic Controls , No ) mfx  bdec(3) sdec(2) keep(t2 t3 t4 t5 period phase2)  label nocons 
		 
xi: probit decision_1 t2 t3 t4 t5 phase2 period share_females_session non_conformity altruism agreeableness num_safe female age student i.religion i.caste i.fam_inc_category if period != 11, cluster (session_id)
mfx
outreg2 using "$replication/tables/Table2.xls"  , append addtext(Behavioral Controls , Yes , Demographic Controls , Yes ) keep(t2 t3 t4 t5 phase2 period  share_females_session) mfx  bdec(3) sdec(2)  label nocons 


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

	   
	   probit group_success1 t2 t3 t4 t5 phase2 if period != 11 ,cluster(session_id)
	   mfx
	   outreg2 using "$replication/tables/Table2.xls", append mfx   addtext(Behavioral Controls , - , Demographic Controls , -)   bdec(3) sdec(2)  label nocons 
	   
	   probit group_success1 t2 t3 t4 t5 phase2 period share_females_session if period != 11, cluster(session_id)
	   mfx
	   outreg2 using "$replication/tables/Table2.xls", append mfx   addtext(Behavioral Controls , - , Demographic Controls , -)   bdec(3) sdec(2)  label nocons
	   
restore

/*last row- unconditional mean for Column 1-3 */
su decision_1 if treatment== 1 & period!=11
/*last row- unconditional mean for Column 4-5 */
su group_success1 if treatment== 1 & period!=11

*---------------------------------------------------------------------------------*
* Footnote 18: Bootstrap SE boot-strapped tests, Kline and Santos 2012 (fulldata) * 
*---------------------------------------------------------------------------------*
set seed 2456789
preserve
    keep if period!=11
    est clear
    constraint 1 female=0
    local clust_var session_id
    
       **baseline**
	
		xi : probit decision_1 female period phase2 share_females_session num_safe agreeableness altruism non_conformity  i.religion i.caste i.fam_inc_category age student  if treatment  == 1 , cluster(`clust_var') 
        boottest, h0(1) //p= 0.02

       **positive**
			
		xi : probit decision_1 female period phase2 share_females_session num_safe agreeableness altruism non_conformity  i.religion i.caste i.fam_inc_category age student  if treatment  == 2, cluster(`clust_var') 
        boottest, h0(1) //0.36
		
       **negative**
			
		xi : probit decision_1 female period phase2 share_females_session num_safe agreeableness altruism non_conformity  i.religion i.caste i.fam_inc_category age student  if treatment  == 3 , cluster(`clust_var') 
        boottest, h0(1) //0.08
		
	   **positive-negative**
			
		xi : probit decision_1 female period phase2 share_females_session num_safe agreeableness altruism non_conformity  i.religion i.caste i.fam_inc_category age student  if treatment  ==4 , cluster(`clust_var') 
        boottest, h0(1) //0.69
		
	    **baseline R**
	
		xi : probit decision_1 fema.le period phase2 share_females_session num_safe agreeableness altruism non_conformity  i.religion i.caste i.fam_inc_category age student  if treatment  == 5 , cluster(`clust_var') 
        boottest, h0(1) //0.06
		
		
restore
*-----------------------------------------------------------------*
* Footnote 19: Prob(Investment) & Female Session Share (fulldata) * 
*-----------------------------------------------------------------*

xi: probit decision_1 share_females_session period t2 t3 t4 t5 phase2 ,cluster(case_id)
mfx
	
*-----------------------------------------------------------------------------*
* Fig 2 note: Test of significance- TotalInvestment between gender (fulldata) *
*-----------------------------------------------------------------------------*

preserve
   keep if period==1
   forvalues i= 1(1)5 {
       ttest n_invest_subject if treatment==`i', by(female) 
	   }
restore 	
	
*-------------------------------------------------*
* Table 3: Probit - Gender Differences (fulldata) * 
*-------------------------------------------------*

preserve 

     keep if period!= 11 
	 
	 levelsof treatment, local(levels) 
     capture outreg using "$replication/tables/Table3.xls" ,replace addtitle(Probit: Gender Differences)
     foreach l of local levels {
	 
 	       probit decision_1 female period phase2  if treatment  == `l' ,  cluster(case_id)
           mfx
           outreg2 using "$replication/tables/Table3.xls"  ,  mfx  addtext(Treatment , T`l' , Behavioral Controls , No , Demographic Controls , No ) bdec(3) sdec(2)  label nocons
		   
           probit decision_1 female period phase2 non_conformity altruism agreeableness num_safe   if treatment  == `l', cluster (case_id)
           mfx
           outreg2 using "$replication/tables/Table3.xls" , mfx  append  addtext(Treatment , T`l' , Behavioral Controls , Yes , Demographic Controls , No ) bdec(3) sdec(2) keep(female period)  label nocons
		   
		   xi : probit decision_1 female period phase2 share_females_session num_safe agreeableness altruism non_conformity  i.religion i.caste i.fam_inc_category age student  if treatment  == `l', cluster (case_id)
           mfx
           outreg2 using "$replication/tables/Table3.xls" , mfx  append  addtext(Treatment , T`l' , Behavioral Controls , Yes , Demographic Controls , Yes) keep(female period phase2 share_females_session ) bdec(3) sdec(2)  label nocons
		   		   
  }
  
restore 

*--------------------------------------------------------*
* Table 4: Probit - Within Gender Differences (alldata)  * 
*--------------------------------------------------------*
label var t2_t1 "Treatment Positve"
label var t3_t1 "Treatment Negative"
label var t4_t1 "Treatment PositiveNegative"
label var t5_t1 "Treatment BaselineR"


* Female only

xi: probit decision_1 t2_t1 period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if female==1, cluster (session_id)
mfx
outreg2 using "$replication/tables/Table4.xls", replace addtext(Behavioral Controls , Yes , Demographic Controls , Yes , Cluster , Session, Sample, Females) keep(t2_t1 period phase2 share_females_session ) mfx bdec(3) sdec(2)  label nocons
		 
xi: probit decision_1 t3_t1 period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if female==1, cluster (session_id)
mfx
outreg2 using "$replication/tables/Table4.xls" , append addtext(Behavioral Controls , Yes , Demographic Controls , Yes , Cluster , Session, Sample, Females) keep(t3_t1 period phase2 share_females_session ) mfx bdec(3) sdec(2)  label nocons 

xi: probit decision_1  t4_t1 period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if female==1, cluster (session_id)
mfx
outreg2 using "$replication/tables/Table4.xls", append addtext(Behavioral Controls , Yes , Demographic Controls , Yes ,  Cluster , Session, Sample, Females) keep(t4_t1 period phase2 share_females_session) mfx bdec(3) sdec(2)  label nocons

xi: probit decision_1 t5_t1 period share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if female==1, cluster (session_id) 
mfx
outreg2 using "$replication/tables/Table4.xls", append addtext(Behavioral Controls , Yes , Demographic Controls , Yes ,  Cluster , Session, Sample, Females) keep(t5_t1 period phase2 share_females_session) mfx bdec(3) sdec(2)  label nocons

* Male only

xi: probit decision_1 t2_t1 period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if female==0, cluster (session_id)
mfx
outreg2 using "$replication/tables/Table4.xls", append addtext(Behavioral Controls , Yes , Demographic Controls , Yes ,  Cluster , Session, Sample, Males) keep(t2_t1 period phase2 share_females_session) mfx bdec(3) sdec(2)  label nocons
		 
xi: probit decision_1 t3_t1 period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if female==0, cluster (session_id)
mfx
outreg2 using "$replication/tables/Table4.xls" , append addtext(Behavioral Controls , Yes , Demographic Controls , Yes ,  Cluster , Session, Sample, Males) keep(t3_t1 period phase2 share_females_session) mfx bdec(3) sdec(2)  label nocons 

xi: probit decision_1  t4_t1 period phase2 share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if female==0, cluster (session_id)
mfx
outreg2 using "$replication/tables/Table4.xls" , append addtext(Behavioral Controls , Yes , Demographic Controls , Yes ,  Cluster , Session, Sample, Males) keep(t4_t1 period phase2 share_females_session) mfx bdec(3) sdec(2)  label nocons 

xi: probit decision_1 t5_t1 period share_females_session non_conformity altruism agreeableness num_safe age student i.religion i.caste i.fam_inc_category if female==0, cluster (session_id) 
mfx
outreg2 using "$replication/tables/Table4.xls", append addtext(Behavioral Controls , Yes , Demographic Controls , Yes ,  Cluster , Session, Sample, Males) keep(t5_t1 period phase2 share_females_session) mfx bdec(3) sdec(2)  label nocons 

