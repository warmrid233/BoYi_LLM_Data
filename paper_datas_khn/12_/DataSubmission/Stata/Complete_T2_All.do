
/******************************************************************************

Choi and Lee, "Communication, Coordination, and Networks," forthcoming to JEEA

Data analysis file for the Complete network with T = 2 treatment

*******************************************************************************/

use Complete_T2_All.dta, clear

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

/* majority */
generate maj1 = m1_ne + m1_ns + m1_nw + m1_es + m1_ew + m1_sw
generate maj2 = m2_ne + m2_ns + m2_nw + m2_es + m2_ew + m2_sw

/* tied-majority */
generate tmaj1 = m1_ne_sw + m1_ns_ew + m1_nw_es
generate tmaj2 = m2_ne_sw + m2_ns_ew + m2_nw_es

/* agreement and disagreement */

generate agree1 = m1_unan + smaj1 + maj1
generate agree2 = m2_unan + smaj2 + maj2
generate tagree1 = m1_unan + smaj1 + maj1 + tmaj1
generate tagree2 = m2_unan + smaj2 + maj2 + tmaj2

/* Table 3 Results */

tab gcoordination if m2_unan == 1 & type == 0
tab gcoordination if smaj2 == 1 & type == 0
tab gcoordination if maj2 == 1 & type == 0
tab gcoordination if tmaj2 == 1 & type == 0 
tab gcoordination if tagree2 == 0 & type == 0


/****************** Unanimity and Super-majority (including the hub(s)): Table 4 *****************/

generate hagree1 = m1_unan + smaj1
generate hagree2 = m2_unan + smaj2

su hagree1 hagree2 if type == 0



/**************************** Table A3-1 ***************************/

bysort type: tab m1

/***************************** Table A3-2: Behavior in the first period and under disagreement ************/

gen fava1 = (m1 == type) 
gen fava2 = (m2 == type) if tagree1 == 0  
gen favaa = (action == type) if tagree2 == 0 

su fava1 fava2 favaa

****************************************************************************************


