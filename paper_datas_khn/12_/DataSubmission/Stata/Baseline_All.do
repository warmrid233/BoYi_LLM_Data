
/******************************************************************************

Choi and Lee, "Communication, Coordination, and Networks," forthcoming to JEEA

Data analysis file for the Baseline treatment (with no communication)

*******************************************************************************/

use Baseline_All.dta, clear

/****** Means and Confidence Intervals of Coordination (Table 1-1, 1-1A-1, 1-1A-2, and Figure 2) ********/

ci gcoordination if session == 1
ci gcoordination if session == 2
ci gcoordination if session == 3
ci gcoordination 

ci gcoordination if session == 1 & period <= 15
ci gcoordination if session == 2 & period <= 15
ci gcoordination if session == 3 & period <= 15
ci gcoordination if period <= 15

ci gcoordination if session == 1 & period >= 16
ci gcoordination if session == 2 & period >= 16
ci gcoordination if session == 3 & period >= 16
ci gcoordination if period >= 16

/******* Coordinated Actions (Table 2, 2A-1)   ********/


tabulate action if gcoordination == 1 & type == 0 & session == 1
tabulate action if gcoordination == 1 & type == 0 & session == 2
tabulate action if gcoordination == 1 & type == 0 & session == 3
tabulate action if gcoordination == 1 & type == 0

tabulate action if gcoordination == 1 & type == 0 & session == 1 & period <= 15
tabulate action if gcoordination == 1 & type == 0 & session == 2 & period <= 15
tabulate action if gcoordination == 1 & type == 0 & session == 3 & period <= 15
tabulate action if gcoordination == 1 & type == 0 & period <= 15

tabulate action if gcoordination == 1 & type == 0 & session == 1 & period > 15
tabulate action if gcoordination == 1 & type == 0 & session == 2 & period > 15
tabulate action if gcoordination == 1 & type == 0 & session == 3 & period > 15
tabulate action if gcoordination == 1 & type == 0 & period > 15

/**************************** Table A3-1 ***************************/

bysort type: tab action


/***************************** Table A3-2 ************/

gen fava = (action == type) 
tab fava

