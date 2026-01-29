/******************************************************************************

Choi and Lee, "Communication, Coordination, and Networks," forthcoming to JEEA

Data analysis file for the Line network with T = 5 treatment

*******************************************************************************/

use Line_T5_All.dta, clear

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
tab gcoordination if ((m5_new == 1)|(m5_esw == 1)) & type == 0
tab gcoordination if ((m5_nsw == 1)|(m5_nes == 1)) & type == 0 
tab gcoordination if m5_ew == 1 & type == 0
tab gcoordination if ((m5_ne == 1)|(m5_es == 1)|(m5_nw == 1)|(m5_sw == 1)) & type == 0 
tab gcoordination if m5_ns == 1 & type == 0 
tab gcoordination if agree5 == 0 & type == 0 

/****************** Unanimity and Super-majority (including the hub(s)): Table 4 *****************/

generate hagree1 = m1_unan + m1_new + m1_esw
generate hagree2 = m2_unan + m2_new + m2_esw
generate hagree3 = m3_unan + m3_new + m3_esw
generate hagree4 = m4_unan + m4_new + m4_esw
generate hagree5 = m5_unan + m5_new + m5_esw

su hagree1 hagree2 hagree3 hagree4 hagree5 if type == 0 

/********************** Behavior of the hub: Table 5-1 *******************************/

/*** Define non-switching behavior (stability) ***/

gen stab = ((m1 == m2)&(m1 == m3)&(m1 == m4)&(m1 == m5)&(m1 == action)) if ((type == 1)|(type == 3))

tab stab if type == 1 | type == 3

tab stab m1 if type == 1, row
tab stab m1 if type == 3, row

/********************* Freq. of non-switching by the hub after initial disagreement ***************/
/* Table 5-2 */

generate stE2 = (stab == 1) if type == 1 & (m1 ~= m1_w) & (m1 ~= m1_s)
generate stW2 = (stab == 1) if type == 3 & (m1 ~= m1_n) & (m1 ~= m1_e)

tab stE2 
tab stW2

/********** Table 5-3: Freq. of coordinated actions cond. on non-switching / switching **********/

bysort stab: tab action if type == 1 & gcoordination == 1

/*********************** Table 6: Behavior of Periphery ***************************/

gen b2_peri = (m2 == m1_e) if (type == 2)&(m1 ~= m1_e)
replace b2_peri = (m2 == m1_w) if (type == 0)&(m1 ~= m1_w)

gen b3_peri = (m3 == m2_e) if (type == 2)&(m2 ~= m2_e)
replace b3_peri = (m3 == m2_w) if (type == 0)&(m2 ~= m2_w)

gen b4_peri = (m4 == m3_e) if (type == 2)&(m3 ~= m3_e)
replace b4_peri = (m4 == m3_w) if (type == 0)&(m3 ~= m3_w)

gen b5_peri = (m5 == m4_e) if (type == 2)&(m4 ~= m4_e)
replace b5_peri = (m5 == m4_w) if (type == 0)&(m4 ~= m4_w)

gen ba_peri = (action == m5_e) if (type == 2)&(m5 ~= m5_e)
replace ba_peri = (action == m5_w) if (type == 0)&(m5 ~= m5_w)

tabstat b2_peri b3_peri b4_peri b5_peri ba_peri, stats(mean sum count)

gen bb2_peri = (m2 == m1_e) if (type == 2)&(m1 == m1_e)
replace bb2_peri = (m2 == m1_w) if (type == 0)&(m1 == m1_w)

gen bb3_peri = (m3 == m2_e) if (type == 2)&(m2 == m2_e)
replace bb3_peri = (m3 == m2_w) if (type == 0)&(m2 == m2_w)

gen bb4_peri = (m4 == m3_e) if (type == 2)&(m3 == m3_e)
replace bb4_peri = (m4 == m3_w) if (type == 0)&(m3 == m3_w)

gen bb5_peri = (m5 == m4_e) if (type == 2)&(m4 == m4_e)
replace bb5_peri = (m5 == m4_w) if (type == 0)&(m4 == m4_w)

gen bba_peri = (action == m5_e) if (type == 2)&(m5 == m5_e)
replace bba_peri = (action == m5_w) if (type == 0)&(m5 == m5_w)

tabstat bb2_peri bb3_peri bb4_peri bb5_peri bba_peri, stats(mean sum count)

************************************************************************************
***********************************************************************************
* Individual Behavior - Table 5A, 6A
***********************************************************************************

/* hub's behavior */

gen ind_nosw = ((m1 == m2)&(m1 == m3)&(m1 == m4)&(m1 == m5)&(m1 == action))
gen ind_nosw_type = ((m1 == m2)&(m1 == m3)&(m1 == m4)&(m1 == m5)&(m1 == action)&(m1 == type)) if ind_nosw == 1

gen cind_nosw = ((m1 == m2)&(m1 == m3)&(m1 == m4)&(m1 == m5))
gen cind_nosw_type = ((m1 == m2)&(m1 == m3)&(m1 == m4)&(m1 == m5)&(m1 == type)) if cind_nosw == 1


collapse ind_nosw ind_nosw_type, by(subject session type)

****
/* Periphery's behavior */

use Line_T5_All.dta, clear


gen ind_perN_2 = (m2 == m1_w) if type == 0 & (m1_nw == 0 & m1_new == 0 & m1_nsw == 0 & m1_unan == 0 & m1_nw_es == 0) 

gen ind_perS_2 = (m2 == m1_e) if type == 2 & (m1_es == 0 & m1_esw == 0 & m1_nes == 0 & m1_unan == 0 & m1_nw_es == 0) 

gen ind_perN_3 = (m3 == m2_w) if type == 0 & (m2_nw == 0 & m2_new == 0 & m2_nsw == 0 & m2_unan == 0 & m2_nw_es == 0) 

gen ind_perS_3 = (m3 == m2_e) if type == 2 & (m2_es == 0 & m2_esw == 0 & m2_nes == 0 & m2_unan == 0 & m2_nw_es == 0) 

gen ind_perN_4 = (m4 == m3_w) if type == 0 & (m3_nw == 0 & m3_new == 0 & m3_nsw == 0 & m3_unan == 0 & m3_nw_es == 0) 

gen ind_perS_4 = (m4 == m3_e) if type == 2 & (m3_es == 0 & m3_esw == 0 & m3_nes == 0 & m3_unan == 0 & m3_nw_es == 0) 

gen ind_perN_5 = (m5 == m4_w) if type == 0 & (m4_nw == 0 & m4_new == 0 & m4_nsw == 0 & m4_unan == 0 & m4_nw_es == 0) 

gen ind_perS_5 = (m5 == m4_e) if type == 2 & (m4_es == 0 & m4_esw == 0 & m4_nes == 0 & m4_unan == 0 & m4_nw_es == 0) 

gen ind_perN_6 = (action == m5_w) if type == 0 & (m5_nw == 0 & m5_new == 0 & m5_nsw == 0 & m5_unan == 0 & m5_nw_es == 0) 

gen ind_perS_6 = (action == m5_e) if type == 2 & (m5_es == 0 & m5_esw == 0 & m5_nes == 0 & m5_unan == 0 & m5_nw_es == 0) 

collapse (mean) ind_perN_2 ind_perN_3 ind_perN_4 ind_perN_5 ind_perN_6 ind_perS_2 ind_perS_3 ind_perS_4 ind_perS_5 ind_perS_6 (count) nN_2 = ind_perN_2 nN_3 = ind_perN_3 nN_4 = ind_perN_4 nN_5 = ind_perN_5 nN_6 = ind_perN_6 nS_2 = ind_perS_2 nS_3 = ind_perS_3 nS_4 = ind_perS_4 nS_5 = ind_perS_5 nS_6 = ind_perS_6 if type == 0 | type == 2, by(subject session type)





