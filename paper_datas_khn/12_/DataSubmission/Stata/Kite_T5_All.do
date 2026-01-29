/******************************************************************************

Choi and Lee, "Communication, Coordination, and Networks," forthcoming to JEEA

Data analysis file for the Kite network with T = 5 treatment

*******************************************************************************/

use Kite_T5_All.dta, clear

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
generate smaj3 = m3_nes + m3_new + m3_nsw + m3_esw
generate smaj4 = m4_nes + m4_new + m4_nsw + m4_esw
generate smaj5 = m5_nes + m5_new + m5_nsw + m5_esw

generate csmaj1 = m1_nes + m1_new + m1_esw
generate csmaj2 = m2_nes + m2_new + m2_esw
generate csmaj3 = m3_nes + m3_new + m3_esw
generate csmaj4 = m4_nes + m4_new + m4_esw
generate csmaj5 = m5_nes + m5_new + m5_esw

/* majority */

generate maj1 = m1_ne + m1_ns + m1_nw + m1_es + m1_ew + m1_sw
generate maj2 = m2_ne + m2_ns + m2_nw + m2_es + m2_ew + m2_sw
generate maj3 = m3_ne + m3_ns + m3_nw + m3_es + m3_ew + m3_sw
generate maj4 = m4_ne + m4_ns + m4_nw + m4_es + m4_ew + m4_sw
generate maj5 = m5_ne + m5_ns + m5_nw + m5_es + m5_ew + m5_sw

/* Disagreement */

generate agree1 = m1_unan + smaj1 + maj1
generate agree2 = m2_unan + smaj2 + maj2
generate agree3 = m3_unan + smaj3 + maj3
generate agree4 = m4_unan + smaj4 + maj4
generate agree5 = m5_unan + smaj5 + maj5


/* Table 3 Results */

tab gcoordination if m5_unan == 1 & type == 0
tab gcoordination if csmaj5 == 1 & type == 0 
tab gcoordination if m5_nsw == 1 & type == 0 
tab gcoordination if ((m5_ne == 1)|(m5_es == 1)|(m5_ew == 1)) & type == 0 
tab gcoordination if ((m5_ns == 1)|(m5_nw == 1)|(m5_sw == 1)) & type == 0 
tab gcoordination if agree5 == 0 & type == 0 

/****************** Unanimity and Super-majority (including the hub(s)): Table 4 *****************/

generate hagree1 = m1_unan + csmaj1
generate hagree2 = m2_unan + csmaj2
generate hagree3 = m3_unan + csmaj3
generate hagree4 = m4_unan + csmaj4
generate hagree5 = m5_unan + csmaj5

su hagree1 hagree2 hagree3 hagree4 hagree5 if type == 0


/********************** Behavior of the hub: Table 5-1 *******************************/

/*** Define non-switching behavior (stability) ***/

generate stab = ((m1 == m2)&(m1 == m3)&(m1 == m4)&(m1 == m5)&(m1 == action)) if type == 1

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
gen b3_peri = (m3 == m2_e) if (type == 3)&(m2 ~= m2_e)
gen b4_peri = (m4 == m3_e) if (type == 3)&(m3 ~= m3_e)
gen b5_peri = (m5 == m4_e) if (type == 3)&(m4 ~= m4_e)
gen ba_peri = (action == m5_e) if (type == 3)&(m5 ~= m5_e)

tabstat b2_peri b3_peri b4_peri b5_peri ba_peri, stats(mean sum count)


gen bb2_peri = (m2 == m1_e) if (type == 3)&(m1 == m1_e)
gen bb3_peri = (m3 == m2_e) if (type == 3)&(m2 == m2_e)
gen bb4_peri = (m4 == m3_e) if (type == 3)&(m3 == m3_e)
gen bb5_peri = (m5 == m4_e) if (type == 3)&(m4 == m4_e)
gen bba_peri = (action == m5_e) if (type == 3)&(m5 == m5_e)

tabstat bb2_peri bb3_peri bb4_peri bb5_peri bba_peri, stats(mean sum count)


/************************* Table 7: Behavior of N and S in the Kite network ****************/

/** When N and S chose a common message which is different from E's **/

gen b2_NS = (m2 == m1) if (type == 0| type == 2) & (m1_ns == 1 | m1_ns_ew == 1)
gen b3_NS = (m3 == m2) if (type == 0| type == 2) & (m2_ns == 1 | m2_ns_ew == 1)
gen b4_NS = (m4 == m3) if (type == 0| type == 2) & (m3_ns == 1 | m3_ns_ew == 1)
gen b5_NS = (m5 == m4) if (type == 0| type == 2) & (m4_ns == 1 | m4_ns_ew == 1)
gen ba_NS = (action == m5) if (type == 0| type == 2) & (m5_ns == 1 | m5_ns_ew == 1)

gen b2_NS_e = (m2 == m1_e) if (type == 0| type == 2) & (m1_ns == 1 | m1_ns_ew == 1)
gen b3_NS_e = (m3 == m2_e) if (type == 0| type == 2) & (m2_ns == 1 | m2_ns_ew == 1)
gen b4_NS_e = (m4 == m3_e) if (type == 0| type == 2) & (m3_ns == 1 | m3_ns_ew == 1)
gen b5_NS_e = (m5 == m4_e) if (type == 0| type == 2) & (m4_ns == 1 | m4_ns_ew == 1)
gen ba_NS_e = (action == m5_e) if (type == 0| type == 2) & (m5_ns == 1 | m5_ns_ew == 1)

tabstat b2_NS b3_NS b4_NS b5_NS ba_NS, stats(mean sum count)
tabstat b2_NS_e b3_NS_e b4_NS_e b5_NS_e ba_NS_e, stats(mean sum count)


/** When N, E, S chose different messages **/

generate sagree1 = m1_unan + smaj1 + m1_ne_sw + m1_ns_ew + m1_nw_es + m1_ne + m1_es + m1_ns
generate sagree2 = m2_unan + smaj2 + m2_ne_sw + m2_ns_ew + m2_nw_es + m2_ne + m2_es + m2_ns
generate sagree3 = m3_unan + smaj3 + m3_ne_sw + m3_ns_ew + m3_nw_es + m3_ne + m3_es + m3_ns
generate sagree4 = m4_unan + smaj4 + m4_ne_sw + m4_ns_ew + m4_nw_es + m4_ne + m4_es + m4_ns
generate sagree5 = m5_unan + smaj5 + m5_ne_sw + m5_ns_ew + m5_nw_es + m5_ne + m5_es + m5_ns

gen b2_NS_c2 = (m2 == m1) if (type == 0| type == 2) & sagree1 == 0
gen b3_NS_c2 = (m3 == m2) if (type == 0| type == 2) & sagree2 == 0
gen b4_NS_c2 = (m4 == m3) if (type == 0| type == 2) & sagree3 == 0
gen b5_NS_c2 = (m5 == m4) if (type == 0| type == 2) & sagree4 == 0
gen ba_NS_c2 = (action == m5) if (type == 0| type == 2) & sagree5 == 0

gen b2_NS_e_c2 = (m2 == m1_e) if (type == 0| type == 2) & sagree1 == 0
gen b3_NS_e_c2 = (m3 == m2_e) if (type == 0| type == 2) & sagree2 == 0
gen b4_NS_e_c2 = (m4 == m3_e) if (type == 0| type == 2) & sagree3 == 0
gen b5_NS_e_c2 = (m5 == m4_e) if (type == 0| type == 2) & sagree4 == 0
gen ba_NS_e_c2 = (action == m5_e) if (type == 0| type == 2) & sagree5 == 0

tabstat b2_NS_c2 b3_NS_c2 b4_NS_c2 b5_NS_c2 ba_NS_c2, stats(mean sum count)
tabstat b2_NS_e_c2 b3_NS_e_c2 b4_NS_e_c2 b5_NS_e_c2 ba_NS_e_c2, stats(mean sum count)

/** When either N or S chose the same message as E **/

gen b2_NS_c3 = (m2 == m1) if ((type == 0)&(m1_esw == 1 | m1_es == 1 | m1_nw_es == 1))|((type == 2)&(m1_new == 1 | m1_ne == 1 | m1_ne_sw == 1))
gen b3_NS_c3 = (m3 == m2) if ((type == 0)&(m2_esw == 1 | m2_es == 1 | m2_nw_es == 1))|((type == 2)&(m2_new == 1 | m2_ne == 1 | m2_ne_sw == 1))
gen b4_NS_c3 = (m4 == m3) if ((type == 0)&(m3_esw == 1 | m3_es == 1 | m3_nw_es == 1))|((type == 2)&(m3_new == 1 | m3_ne == 1 | m3_ne_sw == 1))
gen b5_NS_c3 = (m5 == m4) if ((type == 0)&(m4_esw == 1 | m4_es == 1 | m4_nw_es == 1))|((type == 2)&(m4_new == 1 | m4_ne == 1 | m4_ne_sw == 1))
gen ba_NS_c3 = (action == m5) if ((type == 0)&(m5_esw == 1 | m5_es == 1 | m5_nw_es == 1))|((type == 2)&(m5_new == 1 | m5_ne == 1 | m5_ne_sw == 1))

gen b2_NS_e_c3 = (m2 == m1_e) if ((type == 0)&(m1_esw == 1 | m1_es == 1 | m1_nw_es == 1))|((type == 2)&(m1_new == 1 | m1_ne == 1 | m1_ne_sw == 1))
gen b3_NS_e_c3 = (m3 == m2_e) if ((type == 0)&(m2_esw == 1 | m2_es == 1 | m2_nw_es == 1))|((type == 2)&(m2_new == 1 | m2_ne == 1 | m2_ne_sw == 1))
gen b4_NS_e_c3 = (m4 == m3_e) if ((type == 0)&(m3_esw == 1 | m3_es == 1 | m3_nw_es == 1))|((type == 2)&(m3_new == 1 | m3_ne == 1 | m3_ne_sw == 1))
gen b5_NS_e_c3 = (m5 == m4_e) if ((type == 0)&(m4_esw == 1 | m4_es == 1 | m4_nw_es == 1))|((type == 2)&(m4_new == 1 | m4_ne == 1 | m4_ne_sw == 1))
gen ba_NS_e_c3 = (action == m5_e) if ((type == 0)&(m5_esw == 1 | m5_es == 1 | m5_nw_es == 1))|((type == 2)&(m5_new == 1 | m5_ne == 1 | m5_ne_sw == 1))

tabstat b2_NS_c3 b3_NS_c3 b4_NS_c3 b5_NS_c3 ba_NS_c3, stats(mean sum count)
tabstat b2_NS_e_c3 b3_NS_e_c3 b4_NS_e_c3 b5_NS_e_c3 ba_NS_e_c3, stats(mean sum count)

***********************************************************************************************
***********************************************************************************
* Individual Behavior - Table 5A, 6A
***********************************************************************************

/* hub's behavior */

gen ind_nosw = ((m1 == m2)&(m1 == m3)&(m1 == m4)&(m1 == m5)&(m1 == action))
gen ind_nosw_type = ((m1 == m2)&(m1 == m3)&(m1 == m4)&(m1 == m5)&(m1 == action)&(m1 == type)) if ind_nosw == 1

gen cind_nosw = ((m1 == m2)&(m1 == m3)&(m1 == m4)&(m1 == m5))
gen cind_nosw_type = ((m1 == m2)&(m1 == m3)&(m1 == m4)&(m1 == m5)&(m1 == type)) if cind_nosw == 1


collapse ind_nosw ind_nosw_type cind_nosw cind_nosw_type, by(subject session type)

****

/* Periphery's behavior */

use Kite_T5_All.dta, clear

gen ind_perW_2 = (m2 == m1_e) if type == 3 & (m1_ew == 0 & m1_esw == 0 & m1_new == 0 & m1_unan == 0 & m1_ns_ew == 0) 

gen ind_perW_3 = (m3 == m2_e) if type == 3 & (m2_ew == 0 & m2_esw == 0 & m2_new == 0 & m2_unan == 0 & m2_ns_ew == 0) 

gen ind_perW_4 = (m4 == m3_e) if type == 3 & (m3_ew == 0 & m3_esw == 0 & m3_new == 0 & m3_unan == 0 & m3_ns_ew == 0) 

gen ind_perW_5 = (m5 == m4_e) if type == 3 & (m4_ew == 0 & m4_esw == 0 & m4_new == 0 & m4_unan == 0 & m4_ns_ew == 0) 

gen ind_perW_6 = (action == m5_e) if type == 3 & (m5_ew == 0 & m5_esw == 0 & m5_new == 0 & m5_unan == 0 & m5_ns_ew == 0) 

collapse (mean) ind_perW_2 ind_perW_3 ind_perW_4 ind_perW_5 ind_perW_6 (count) nW_2 = ind_perW_2 nW_3 = ind_perW_3 nW_4 = ind_perW_4 nW_5 = ind_perW_5 nW_6 = ind_perW_6 if type == 3, by(subject session type)




