
/******************************************************************************

Choi and Lee, "Communication, Coordination, and Networks," forthcoming to JEEA

Data analysis file for the Wilcoxon Rank-sum test: Table 1-2 (a) and (b)

*******************************************************************************/

use DataAll.dta, clear

gen id_treatment = 10*network + time

/*************************************************************************
* Wilcoxon (Mann-Whitney) Ranksum test: Table 1-2 (a) ********************
**************************************************************************/

/* between T=2 and T= 5 */

bysort network: ranksum gcoordination if type == 0, by(time)

/* Fix complete network */

ranksum gcoordination if type == 0 & time == 2 & (network == 1 | network == 2), by(network)
ranksum gcoordination if type == 0 & time == 2 & (network == 1 | network == 3), by(network)
ranksum gcoordination if type == 0 & time == 2 & (network == 1 | network == 4), by(network)

ranksum gcoordination if type == 0 & time == 5 & (network == 1 | network == 2), by(network)
ranksum gcoordination if type == 0 & time == 5 & (network == 1 | network == 3), by(network)
ranksum gcoordination if type == 0 & time == 5 & (network == 1 | network == 4), by(network)

/* Fix star network */

ranksum gcoordination if type == 0 & time == 2 & (network == 2 | network == 3), by(network)
ranksum gcoordination if type == 0 & time == 2 & (network == 2 | network == 4), by(network)

ranksum gcoordination if type == 0 & time == 5 & (network == 2 | network == 3), by(network)
ranksum gcoordination if type == 0 & time == 5 & (network == 2 | network == 4), by(network)

/* Fix kite network */

ranksum gcoordination if type == 0 & time == 2 & (network == 3 | network == 4), by(network)

ranksum gcoordination if type == 0 & time == 5 & (network == 3 | network == 4), by(network)


************************


/* Fix complete T = 2 (id == 12)*/

ranksum gcoordination if type == 0 & (id_treatment == 12 | id_treatment == 25), by(id_treatment)
ranksum gcoordination if type == 0 & (id_treatment == 12 | id_treatment == 35), by(id_treatment)
ranksum gcoordination if type == 0 & (id_treatment == 12 | id_treatment == 45), by(id_treatment)
ranksum gcoordination if type == 0 & (id_treatment == 12 | id_treatment == 50), by(id_treatment)


/* Fix complete T = 5 (id == 15)*/

ranksum gcoordination if type == 0 & (id_treatment == 15 | id_treatment == 22), by(id_treatment)
ranksum gcoordination if type == 0 & (id_treatment == 15 | id_treatment == 32), by(id_treatment)
ranksum gcoordination if type == 0 & (id_treatment == 15 | id_treatment == 42), by(id_treatment)
ranksum gcoordination if type == 0 & (id_treatment == 15 | id_treatment == 50), by(id_treatment)


/* Fix star T = 2 (id == 22)*/

ranksum gcoordination if type == 0 & (id_treatment == 22 | id_treatment == 35), by(id_treatment)
ranksum gcoordination if type == 0 & (id_treatment == 22 | id_treatment == 45), by(id_treatment)
ranksum gcoordination if type == 0 & (id_treatment == 22 | id_treatment == 50), by(id_treatment)


/* Fix star T = 5 (id == 25)*/

ranksum gcoordination if type == 0 & (id_treatment == 25 | id_treatment == 32), by(id_treatment)
ranksum gcoordination if type == 0 & (id_treatment == 25 | id_treatment == 42), by(id_treatment)
ranksum gcoordination if type == 0 & (id_treatment == 25 | id_treatment == 50), by(id_treatment)


/* Fix kite T = 2 (id == 32)*/

ranksum gcoordination if type == 0 & (id_treatment == 32 | id_treatment == 45), by(id_treatment)
ranksum gcoordination if type == 0 & (id_treatment == 32 | id_treatment == 50), by(id_treatment)


/* Fix kite T = 5 (id == 35)*/

ranksum gcoordination if type == 0 & (id_treatment == 35 | id_treatment == 42), by(id_treatment)
ranksum gcoordination if type == 0 & (id_treatment == 35 | id_treatment == 50), by(id_treatment)


/* Fix Line T = 2 (id == 42)*/

ranksum gcoordination if type == 0 & (id_treatment == 42 | id_treatment == 50), by(id_treatment)


/* Fix Line T = 5 (id == 45)*/

ranksum gcoordination if type == 0 & (id_treatment == 45 | id_treatment == 50), by(id_treatment)


/*******************************************************
******  Session-level analysis: Table 1-2 (b) **********
*******************************************************/


collapse gcoordination, by(id_treatment session)


/* Fix complete T=2 (12) */


ttest gcoordination if id_treatment == 12 | id_treatment == 15, by(id_treatment)
ttest gcoordination if id_treatment == 12 | id_treatment == 22, by(id_treatment)
ttest gcoordination if id_treatment == 12 | id_treatment == 25, by(id_treatment)
ttest gcoordination if id_treatment == 12 | id_treatment == 32, by(id_treatment)
ttest gcoordination if id_treatment == 12 | id_treatment == 35, by(id_treatment)
ttest gcoordination if id_treatment == 12 | id_treatment == 42, by(id_treatment)
ttest gcoordination if id_treatment == 12 | id_treatment == 45, by(id_treatment)
ttest gcoordination if id_treatment == 12 | id_treatment == 50, by(id_treatment)


/* Fix complete T=5 (15) */

ttest gcoordination if id_treatment == 15 | id_treatment == 22, by(id_treatment)
ttest gcoordination if id_treatment == 15 | id_treatment == 25, by(id_treatment)
ttest gcoordination if id_treatment == 15 | id_treatment == 32, by(id_treatment)
ttest gcoordination if id_treatment == 15 | id_treatment == 35, by(id_treatment)
ttest gcoordination if id_treatment == 15 | id_treatment == 42, by(id_treatment)
ttest gcoordination if id_treatment == 15 | id_treatment == 45, by(id_treatment)
ttest gcoordination if id_treatment == 15 | id_treatment == 50, by(id_treatment)


/* Fix Star T=2 (22) */

ttest gcoordination if id_treatment == 22 | id_treatment == 25, by(id_treatment)
ttest gcoordination if id_treatment == 22 | id_treatment == 32, by(id_treatment)
ttest gcoordination if id_treatment == 22 | id_treatment == 35, by(id_treatment)
ttest gcoordination if id_treatment == 22 | id_treatment == 42, by(id_treatment)
ttest gcoordination if id_treatment == 22 | id_treatment == 45, by(id_treatment)
ttest gcoordination if id_treatment == 22 | id_treatment == 50, by(id_treatment)

/* Fix Star T=5 (22) */

ttest gcoordination if id_treatment == 25 | id_treatment == 32, by(id_treatment)
ttest gcoordination if id_treatment == 25 | id_treatment == 35, by(id_treatment)
ttest gcoordination if id_treatment == 25 | id_treatment == 42, by(id_treatment)
ttest gcoordination if id_treatment == 25 | id_treatment == 45, by(id_treatment)
ttest gcoordination if id_treatment == 25 | id_treatment == 50, by(id_treatment)


/* Fix Kite T=2 (32) */

ttest gcoordination if id_treatment == 32 | id_treatment == 35, by(id_treatment)
ttest gcoordination if id_treatment == 32 | id_treatment == 42, by(id_treatment)
ttest gcoordination if id_treatment == 32 | id_treatment == 45, by(id_treatment)
ttest gcoordination if id_treatment == 32 | id_treatment == 50, by(id_treatment)


/* Fix Kite T=5 (35) */

ttest gcoordination if id_treatment == 35 | id_treatment == 42, by(id_treatment)
ttest gcoordination if id_treatment == 35 | id_treatment == 45, by(id_treatment)
ttest gcoordination if id_treatment == 35 | id_treatment == 50, by(id_treatment)


/* Fix Line T=2 (42) */

ttest gcoordination if id_treatment == 42 | id_treatment == 45, by(id_treatment)
ttest gcoordination if id_treatment == 42 | id_treatment == 50, by(id_treatment)


/* Fix Line T=5 (45) */

ttest gcoordination if id_treatment == 45 | id_treatment == 50, by(id_treatment)

