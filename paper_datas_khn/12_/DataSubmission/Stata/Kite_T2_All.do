/******************************************************************************

Choi and Lee, "Communication, Coordination, and Networks," forthcoming to JEEA

Data analysis file for the Kite network with T = 2 treatment

*******************************************************************************/

use Kite_T2_All.dta, clear

/****** Means and Confidence Intervals of Coordination (Table 1-1, 1-1A-1, 1-1A-2, and Figure 2) ********/

ci gcoordination if session == 1 & type == 0
ci gcoordination if session == 2 & type == 0
ci gcoordination if session == 3 & type == 0
ci gcoordination if type == 0

ci gcoordination if session == 1 & type == 0 & period <= 10
ci gcoordination if session == 2 & type == 0 & period <= 10
ci gcoordination if session == 3 & type == 0 & period <= 10
ci gcoordination if type == 0 & period <= 10

ci gcoordination if session == 1 & type == 0 & period > 10
ci gcoordination if session == 2 & type == 0 & period > 10
ci gcoordination if session == 3 & type == 0 & period > 10
ci gcoordination if type == 0 & period > 10


/******* Coordinated Actions (Table 2, 2A-1)   ********/

tabulate action if gcoordination == 1 & type == 0 & session == 1
tabulate action if gcoordination == 1 & type == 0 & session == 2
tabulate action if gcoordination == 1 & type == 0 & session == 3
tabulate action if gcoordination == 1 & type == 0

tabulate action if gcoordination == 1 & type == 0 & session == 1 & period <= 10
tabulate action if gcoordination == 1 & type == 0 & session == 2 & period <= 10
tabulate action if gcoordination == 1 & type == 0 & session == 3 & period <= 10
tabulate action if gcoordination == 1 & type == 0 & period <= 10

tabulate action if gcoordination == 1 & type == 0 & session == 1 & period > 10
tabulate action if gcoordination == 1 & type == 0 & session == 2 & period > 10
tabulate action if gcoordination == 1 & type == 0 & session == 3 & period > 10
tabulate action if gcoordination == 1 & type == 0 & period > 10

gen taction_all = action if gcoordination == 1 & type == 0
csgof taction_all, expperc( 25 25 25 25) 

gen taction_s1 = action if gcoordination == 1 & session == 1 & type == 0
csgof taction_s1, expperc( 25 25 25 25) 

gen taction_s2 = action if gcoordination == 1 & session == 2 & type == 0
csgof taction_s2, expperc( 25 25 25 25) 

gen taction_s3 = action if gcoordination == 1 & session == 3 & type == 0
csgof taction_s3, expperc( 25 25 25 25) 


/***** Relation between communication and coordination (Table 3) ******/

/* supermajority */
generate smaj1 = m1_nes + m1_new + m1_nsw + m1_esw
generate smaj2 = m2_nes + m2_new + m2_nsw + m2_esw

generate csmaj1 = m1_nes + m1_new + m1_esw
generate csmaj2 = m2_nes + m2_new + m2_esw

/* majority */

generate maj1 = m1_ne + m1_ns + m1_nw + m1_es + m1_ew + m1_sw
generate maj2 = m2_ne + m2_ns + m2_nw + m2_es + m2_ew + m2_sw

/* Disagreement */

generate agree1 = m1_unan + smaj1 + maj1
generate agree2 = m2_unan + smaj2 + maj2


/* Table 3 Results */

tab gcoordination if m2_unan == 1 & type == 0
tab gcoordination if csmaj2 == 1 & type == 0 
tab gcoordination if m2_nsw == 1 & type == 0 
tab gcoordination if ((m2_ne == 1)|(m2_es == 1)|(m2_ew == 1)) & type == 0 
tab gcoordination if ((m2_ns == 1)|(m2_nw == 1)|(m2_sw == 1)) & type == 0 
tab gcoordination if agree2 == 0 & type == 0 

/****************** Unanimity and Super-majority (including the hub(s)): Table 4 *****************/

generate hagree1 = m1_unan + csmaj1
generate hagree2 = m2_unan + csmaj2

su hagree1 hagree2 if type == 0


/********************** Behavior of the hub: Table 5-1 *******************************/

/*** Define non-switching behavior (stability) ***/

generate stab = ((m1 == m2)&(m1 == action)) if type == 1

tab stab if type == 1 
tab stab m1 if type == 1, row


/********************* Freq. of non-switching by the hub after initial disagreement ***************/
/* Table 5-2 */

gen stE2 = (stab == 1) if type == 1 & (m1 ~= m1_n) & (m1 ~= m1_s) & (m1 ~= m1_w)

tab stE2

/********** Table 5-3: Freq. of coordinated actions cond. on non-switching / switching **********/

bysort stab: tab action if type == 1 & gcoordination == 1


/*********************** Table 6: Behavior of Periphery ***************************/

gen b2_peri = (m2 == m1_e) if (type == 3)&(m1 ~= m1_e)
gen ba_peri = (action == m2_e) if (type == 3)&(m2 ~= m2_e)

tabstat b2_peri ba_peri, stats(mean sum count)

gen bb2_peri = (m2 == m1_e) if (type == 3)&(m1 == m1_e)
gen bba_peri = (action == m2_e) if (type == 3)&(m2 == m2_e)

tabstat bb2_peri bba_peri, stats(mean sum count)


/************************* Table 7: Behavior of N and S in the Kite network ****************/

/** When N and S chose a common message which is different from E's **/

gen b2_NS = (m2 == m1) if (type == 0| type == 2) & (m1_ns == 1 | m1_ns_ew == 1)
gen ba_NS = (action == m2) if (type == 0| type == 2) & (m2_ns == 1 | m2_ns_ew == 1)

gen b2_NS_e = (m2 == m1_e) if (type == 0| type == 2) & (m1_ns == 1 | m1_ns_ew == 1)
gen ba_NS_e = (action == m2_e) if (type == 0| type == 2) & (m2_ns == 1 | m2_ns_ew == 1)

tabstat b2_NS ba_NS, stats(mean sum count)
tabstat b2_NS_e ba_NS_e, stats(mean sum count)

/** When N, E, S chose different messages **/

gen sagree1 = m1_unan + smaj1 + m1_ne_sw + m1_ns_ew + m1_nw_es + m1_ne + m1_es + m1_ns
gen sagree2 = m2_unan + smaj2 + m2_ne_sw + m2_ns_ew + m2_nw_es + m2_ne + m2_es + m2_ns

gen b2_NS_c2 = (m2 == m1) if (type == 0| type == 2) & sagree1 == 0
gen ba_NS_c2 = (action == m2) if (type == 0| type == 2) & sagree2 == 0

gen b2_NS_e_c2 = (m2 == m1_e) if (type == 0| type == 2) & sagree1 == 0
gen ba_NS_e_c2 = (action == m2_e) if (type == 0| type == 2) & sagree2 == 0

tabstat b2_NS_c2 ba_NS_c2, stats(mean sum count)
tabstat b2_NS_e_c2 ba_NS_e_c2, stats(mean sum count)

/** When either N or S chose the same message as E **/

gen b2_NS_c3 = (m2 == m1) if ((type == 0)&(m1_esw == 1 | m1_es == 1 | m1_nw_es == 1))|((type == 2)&(m1_new == 1 | m1_ne == 1 | m1_ne_sw == 1))
gen ba_NS_c3 = (action == m2) if ((type == 0)&(m2_esw == 1 | m2_es == 1 | m2_nw_es == 1))|((type == 2)&(m2_new == 1 | m2_ne == 1 | m2_ne_sw == 1))

gen b2_NS_e_c3 = (m2 == m1_e) if ((type == 0)&(m1_esw == 1 | m1_es == 1 | m1_nw_es == 1))|((type == 2)&(m1_new == 1 | m1_ne == 1 | m1_ne_sw == 1))
gen ba_NS_e_c3 = (action == m2_e) if ((type == 0)&(m2_esw == 1 | m2_es == 1 | m2_nw_es == 1))|((type == 2)&(m2_new == 1 | m2_ne == 1 | m2_ne_sw == 1))

tabstat b2_NS_c3 ba_NS_c3, stats(mean sum count)
tabstat b2_NS_e_c3 ba_NS_e_c3, stats(mean sum count)

*****************************************************************************
***********************************************************************************
* Individual Behavior - Table 5A, 6A
***********************************************************************************

/* hub's behavior */

gen ind_nosw = ((m1 == m2)&(m1 == action))
gen ind_nosw_type = ((m1 == m2)&(m1 == action)&(m1 == type)) if ind_nosw == 1

gen cind_nosw = (m1 == m2)
gen cind_nosw_type = ((m1 == m2)&(m1 == type)) if cind_nosw == 1


collapse ind_nosw ind_nosw_type cind_nosw cind_nosw_type, by(subject session type)


*** player W

use Kite_T2_All.dta, clear


gen ind_perW_2 = (m2 == m1_e) if type == 3 & (m1_ew == 0 & m1_esw == 0 & m1_new == 0 & m1_unan == 0 & m1_ns_ew == 0) 

gen ind_perW_3 = (action == m2_e) if type == 3 & (m2_ew == 0 & m2_esw == 0 & m2_new == 0 & m2_unan == 0 & m2_ns_ew == 0) 

collapse (mean) ind_perW_2 ind_perW_3 (count) nW2 = ind_perW_2 nW3 = ind_perW_3 if type == 3, by(subject session type)


