Data and do-file accompanying "On the Effects of Grup Identity in Strategic Environments”
By Chloe Le Coq, James Tremewan, Alexander K. Wagner

This zip-file contains the following four files:
 
CentipedeGame.dta
--> this file contains the raw data in STATA-format (.dta). For compiling and analyzing the data we have used STATA13.

CentipedeGame_Regressions.dta
--> this file contains the raw data in STATA-format (.dta). For compiling and analyzing the data we have used STATA13.

StagHunt.dta
--> this file contains the raw data in STATA-format (.dta). For compiling and analyzing the data we have used STATA13.


GroupIdentity.do
The do-file reports the data analysis.



DESCRIPTION OF DATA in file CentipedeGame.dta

Variables
- ingroup. dummy 1=yes
- player. Role 1 or 2
-strategy:	1=stop at first node
		2=stop at second node
		3=stop at third node
		4=always continue
- gamepayoff. profit from game
- subject. unique subject ID
- belief(1-3). number of subjects in other role expected to continue at subsequent node


DESCRIPTION OF DATA in file CentipedeGame_Regressions.dta

Variables
- decision. decision number
- ingroup. dummy 1=yes
- player. Role 1 or 2
- continue. dummy 1=yes
- subject. unique subject ID
- belief. number of subjects in other role expected to continue at subsequent node


DESCRIPTION OF DATA in file StagHunt.dta

Variables
- ingroup. dummy 1=yes
- choice. 0=Up; 1=Middle; 2=Down
- beliefL/C/R. Probability with which subject believes partner will play each action
- game. Game # as shown in Figure 3
- BRUR. dummy 1=subject chooses BRUR action
- choiceU/D. subject chooses Up/Down
- BRURbelief.  Probability with which subject believes partner will play BRUR
- distance_uniform. Euclidean distance between elicited belief and uniform randomization