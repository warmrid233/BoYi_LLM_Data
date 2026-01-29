
/******************************************************************************

Choi and Lee, "Communication, Coordination, and Networks," forthcoming to JEEA

Data analysis file for the Complete network with T = 5 treatment

*******************************************************************************/

use Complete_T5_All.dta, clear


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

/* tied-majority */
generate tmaj1 = m1_ne_sw + m1_ns_ew + m1_nw_es
generate tmaj2 = m2_ne_sw + m2_ns_ew + m2_nw_es
generate tmaj3 = m3_ne_sw + m3_ns_ew + m3_nw_es
generate tmaj4 = m4_ne_sw + m4_ns_ew + m4_nw_es
generate tmaj5 = m5_ne_sw + m5_ns_ew + m5_nw_es

/* agreement and disagreement */

generate agree1 = m1_unan + smaj1 + maj1
generate agree2 = m2_unan + smaj2 + maj2
generate agree3 = m3_unan + smaj3 + maj3
generate agree4 = m4_unan + smaj4 + maj4
generate agree5 = m5_unan + smaj5 + maj5

generate tagree1 = m1_unan + smaj1 + maj1 + tmaj1
generate tagree2 = m2_unan + smaj2 + maj2 + tmaj2
generate tagree3 = m3_unan + smaj3 + maj3 + tmaj3
generate tagree4 = m4_unan + smaj4 + maj4 + tmaj4
generate tagree5 = m5_unan + smaj5 + maj5 + tmaj5

/**** Table 3 results ****/

tab gcoordination if m5_unan == 1 & type == 0
tab gcoordination if smaj5 == 1 & type == 0
tab gcoordination if maj5 == 1 & type == 0
tab gcoordination if tmaj5 == 1 & type == 0
tab gcoordination if tagree5 == 0 & type == 0


/****************** Unanimity and Super-majority (including the hub(s)): Table 4 *****************/

generate hagree1 = m1_unan + smaj1
generate hagree2 = m2_unan + smaj2
generate hagree3 = m3_unan + smaj3
generate hagree4 = m4_unan + smaj4
generate hagree5 = m5_unan + smaj5

su hagree1 hagree2 hagree3 hagree4 hagree5 if type == 0


/**************************** Table A3-1 ***************************/

bysort type: tab m1

/***************************** Table A3-2: Behavior in the first period and under disagreement ************/

gen fava1 = (m1 == type) 
gen fava2 = (m2 == type) if tagree1 == 0  
gen fava3 = (m3 == type) if tagree2 == 0  
gen fava4 = (m4 == type) if tagree3 == 0  
gen fava5 = (m5 == type) if tagree4 == 0  
gen favaa = (action == type) if tagree5 == 0 

su fava1 fava2 fava3 fava4 fava5 favaa if session == 1
su fava1 fava2 fava3 fava4 fava5 favaa

******************************************************************

