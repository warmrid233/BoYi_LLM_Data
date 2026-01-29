
 clear all
 
 *cd "H:\endogenous groups\EndogenousGroups"
 
 cd "C:\Documents\EndogenousGroups\Immigration\Experiments\analysis\new" 
 * it's easier to comment and uncomment these lines for different directory structures rather than deleting and then I restore this one
 
 use ".\Immigration1_7_2014", clear


drop if omitted==1

log using ".\LogFile.smcl", replace


xtset SubjectID period 


****** Produces Data for Table 1
* MinPublic and GroupSize data calculated in section below focusing on group level calculations
table treatment if period>3 & period<11 & HighGroup==0, c (mean public  mean profit)
table treatment if period>15 & HighGroup==0, c (mean public  mean profit) 

table treatment if period>3 & period<11 & HighGroup==1, c (mean public mean profit)
table treatment if period>15 & HighGroup==1, c (mean public  mean profit) 
//numbers from quiz and quota treatments are reversed in table 1 in the paper


*** PRODUCES DATA FOR TABLES THAT GO INTO FIGURE 1 
*S-Plus was used for existing figures. 
*See Excel file for how to format data to be dropped into s-plus data files.
* Data for MinPublic calculated below since it has to be done off of group level data.

 table period treatment if period > 0 & HighGroup==1, c(mean public)
 
 

*** PRODUCES DATA FOR TABLES THAT GO INTO FIGURE 2 
* Same notes as for Figure 1. Group size data calculated below.

table period treatment if period > 0 & HighGroup==1, c(mean profit)
 * drop groups, where in Period 10 (Beginning Stage 2) Low-Groups had a higher or equal minimum contribution than high-Groups


*** PRODUCES DATA FOR TABLES THAT GO INTO FIGURE 3
*average successful moves per period per group
table period treatment if period > 10, c(mean NumberMove) 

*average attempted moves per period per group
replace attempt = . if attempt==-1 | attempt==0 /*to sum up in the next command, how many subjects wanted to move per family per period*/
egen NumberAttempt = sum(attempt), by(Family period) 

table period treatment if period > 10, c(mean NumberAttempt) 

  
 
*** Data for tests in table 2
bysort treatment: table period GroupID if HighGroup==1, c(mean public ) 
*generates group level observations used in the tests. Have to test after putting this into a separate data file
* and doing summary calcuations.
* the same is true for the minpublic data generated above
 

***TABLE 3 Columns 1-4
* column 5 is calculated in group analysis below

xtreg public GroupSize period Entry Quiz QuizXEntry QuizBQuota Phase2 EntryP2 QuizP2  QuizXEntryP2 QuizBQuotaP2 HighGroup HighXGroupSize HighXperiod HighXEntry HighXQuiz HighXQuizXEntry HighXQuizBQuota if InitHigh==0 & period>3,re vce(cluster SubjectID)

lincom HighXEntry - HighXQuiz
lincom HighXEntry - HighXQuizXEntry
lincom HighXQuiz - HighXQuizXEntry
lincom HighXQuizBQuota-HighXQuiz
lincom HighXQuizBQuota-HighXQuizXEntry



outreg2 using Table3, tex replace

xtreg public GroupSize period Entry Quiz QuizXEntry QuizBQuota Phase2 EntryP2 QuizP2  QuizXEntryP2 QuizBQuotaP2 if InitHigh==1 & period>3,re vce(cluster SubjectID)

lincom EntryP2 - QuizP2
lincom EntryP2 - QuizXEntryP2
lincom QuizP2 - QuizXEntryP2
lincom QuizBQuota-Quiz
lincom QuizBQuota-QuizXEntry

outreg2 using Table3, tex 

lincom Phase2+EntryP2
lincom Phase2+QuizP2
lincom Phase2+QuizXEntryP2
lincom Phase2+QuizBQuotaP2

xtreg profit GroupSize period Entry Quiz QuizXEntry QuizBQuota Phase2 EntryP2 QuizP2  QuizXEntryP2 QuizBQuotaP2 HighGroup HighXGroupSize HighXperiod HighXEntry HighXQuiz HighXQuizXEntry HighXQuizBQuota if InitHigh==0 & period>3,re vce(cluster SubjectID)

lincom HighXEntry - HighXQuiz
lincom HighXEntry - HighXQuizXEntry
lincom HighXQuiz - HighXQuizXEntry

outreg2 using Table3, tex 

xtreg profit GroupSize period Entry Quiz QuizXEntry QuizBQuota Phase2 EntryP2 QuizP2  QuizXEntryP2 QuizBQuotaP2 if InitHigh==1 & period>3,re vce(cluster SubjectID)
lincom EntryP2 - QuizP2
lincom EntryP2 - QuizXEntryP2
lincom QuizP2 - QuizXEntryP2


outreg2 using Table3, tex 

lincom Phase2+EntryP2
lincom Phase2+QuizP2
lincom Phase2+QuizXEntryP2
lincom Phase2+QuizBQuotaP2




******* Table 3a

xtreg public GroupSize period Entry Quiz QuizXEntry Phase2 EntryP2 QuizP2  QuizXEntryP2 HighGroup HighXGroupSize HighXperiod HighXEntry HighXQuiz HighXQuizXEntry if InitHigh==0 & period>3 & treatment>1,re vce(cluster SubjectID)
outreg2 using Table3a, tex replace

xtreg public GroupSize period Entry Quiz QuizXEntry Phase2 EntryP2 QuizP2  QuizXEntryP2 if InitHigh==1 & period>3 & treatment>1,re vce(cluster SubjectID)
outreg2 using Table3a, tex 


xtreg profit GroupSize period Entry Quiz QuizXEntry Phase2 EntryP2 QuizP2  QuizXEntryP2 HighGroup HighXGroupSize HighXperiod HighXEntry HighXQuiz HighXQuizXEntry if InitHigh==0 & period>3 & treatment>1,re vce(cluster SubjectID)
outreg2 using Table3a, tex 

xtreg profit GroupSize period Entry Quiz QuizXEntry Phase2 EntryP2 QuizP2  QuizXEntryP2 if InitHigh==1 & period>3 & treatment>1,re vce(cluster SubjectID)
outreg2 using Table3a, tex 


*** TABLE 4

*produces top left quadrant but not the part in ()
 table AfterMove1 treatment if (PriorToMove1 == 1 | AfterMove1 == 1), c(mean public)
*produces top left quadrant in ()
 table AfterMove1 treatment if (PriorToMove1 == 1 | AfterMove1 == 1) & MovePeriod==11, c(mean public)
*produces bottom left 
 table AfterMove3 treatment if (PriorToMove3 == 1 | AfterMove3 == 1), c(mean public) // I guess that table 4 in the paper doesn't show the right numbers. Look at the bottom left cell, second column, first and second numbers
*produces top right
gen OriginalHigh = 1 if period==10&HighGroup==1 //produces dummy to identify original high group members (due to the separation after stage 1)
egen e_OriginalHigh = max(OriginalHigh), by (SubjectID) //transfers identified original high group members to other periods
replace OriginalHigh = e_OriginalHigh //transfers identified original high group members to other periods (create an auxiliary variable)
drop e_OriginalHigh //transfers identified original high group members to other periods (drop the used auxiliary variable)
gen BeforeStage3 = 0 if period==10&OriginalHigh==1 //produces dummy to identify public contribution from original high group members 1 period before Stage 3 begins
replace BeforeStage3 = 1 if period==11&OriginalHigh==1 //produces dummy to identify public contribution from original high group members 1 period after Stage 3 began
 table BeforeStage3 treatment if (BeforeStage3 == 0 | BeforeStage3 == 1), c(mean public)
*produces bottom right
gen BeforeStage33 = 0 if period>7 & period<11 & OriginalHigh==1 //produces dummy to identify public contributions from original high group members 3 periods before Stage 3 begins
replace BeforeStage33 = 1 if period>10 & period<14 & OriginalHigh==1 //produces dummy to identify public contributions from original high group members 3 periods after Stage 3 began
 table BeforeStage33 treatment if (BeforeStage33 == 0 | BeforeStage33==1), c(mean public)



*** TABLE 5 

regress Contrib1After MinPublicLastPeriod Contrib1Before Entry Quiz  QuizXEntry QuizBQuota, vce(robust)
outreg2 using Table5, tex replace
regress Contrib3After MinPublicLastPeriod Contrib3Before Entry Quiz  QuizXEntry QuizBQuota, vce(robust)
outreg2 using Table5, tex

regress Contrib1AfterInc MinPublicLastPeriod  Entry Quiz QuizXEntry QuizBQuota Stage1Min, vce(robust)
outreg2 using Table5, tex
regress Contrib3AfterInc MinPublicLastPeriod Entry Quiz QuizXEntry QuizBQuota Stage1Min, vce(robust)
outreg2 using Table5, tex



* TABLE 6

*row 1
table OriginalHigh treatment if period==11
*row 2
table OriginalHigh treatment if period==11 & public==MinPublic & OriginalHigh==1
*row 3
table period treatment if period > 0 & attempt>-1, c(sum move)
*row 4
table move treatment if period==11 & public==MinPublic & move==1



***********************************************************************************************************
*Round 2 Analysis
***********************************************************************************************************

***TABLE 3 alternate Columns 1-4
* column 5 is calculated in group analysis below
* leave out QuizB quota and add Zurich Dummy

xtreg public GroupSize period Entry Quiz QuizXEntry  Phase2 EntryP2 QuizP2  QuizXEntryP2 HighGroup HighXGroupSize HighXperiod HighXEntry HighXQuiz HighXQuizXEntry if InitHigh==0 & period>3 & QuizBQuota==0 & zurich==0,re vce(cluster SubjectID)
outreg2 using Table3alt, tex replace
xtreg public GroupSize period Entry Quiz QuizXEntry  Phase2 EntryP2 QuizP2  QuizXEntryP2 HighGroup HighXGroupSize HighXperiod HighXEntry HighXQuiz HighXQuizXEntry if InitHigh==0 & period>3 & QuizBQuota==0 & zurich==1,re vce(cluster SubjectID)
outreg2 using Table3alt, tex 



xtreg public GroupSize period Entry Quiz QuizXEntry Phase2 EntryP2 QuizP2  QuizXEntryP2 if InitHigh==1 & period>3 & QuizBQuota==0 & zurich==0,re vce(cluster SubjectID)
outreg2 using Table3alt, tex
xtreg public GroupSize period Entry Quiz QuizXEntry Phase2 EntryP2 QuizP2  QuizXEntryP2 if InitHigh==1 & period>3 & QuizBQuota==0 & zurich==1,re vce(cluster SubjectID)
outreg2 using Table3alt, tex 



xtreg profit GroupSize period Entry Quiz QuizXEntry Phase2 EntryP2 QuizP2  QuizXEntryP2  HighGroup HighXGroupSize HighXperiod HighXEntry HighXQuiz HighXQuizXEntry  if InitHigh==0 & period>3 & QuizBQuota==0 & zurich==0,re vce(cluster SubjectID)
outreg2 using Table3alt, tex
xtreg profit GroupSize period Entry Quiz QuizXEntry Phase2 EntryP2 QuizP2  QuizXEntryP2  HighGroup HighXGroupSize HighXperiod HighXEntry HighXQuiz HighXQuizXEntry  if InitHigh==0 & period>3 & QuizBQuota==0 & zurich==1,re vce(cluster SubjectID)
outreg2 using Table3alt, tex


xtreg profit GroupSize period Entry Quiz QuizXEntry  Phase2 EntryP2 QuizP2  QuizXEntryP2  if InitHigh==1 & period>3 & QuizBQuota==0 & zurich==0,re vce(cluster SubjectID)
outreg2 using Table3alt, tex
xtreg profit GroupSize period Entry Quiz QuizXEntry  Phase2 EntryP2 QuizP2  QuizXEntryP2  if InitHigh==1 & period>3 & QuizBQuota==0 & zurich==1,re vce(cluster SubjectID)
outreg2 using Table3alt, tex

 
xtreg public zurich GroupSize period Entry Quiz QuizXEntry  Phase2 EntryP2 QuizP2  QuizXEntryP2 HighGroup HighXGroupSize HighXperiod HighXEntry HighXQuiz HighXQuizXEntry if InitHigh==0 & period>3 & QuizBQuota==0 ,re vce(cluster SubjectID)
outreg2 using Table3alt2, tex replace
xtreg public zurich GroupSize period Entry Quiz QuizXEntry Phase2 EntryP2 QuizP2  QuizXEntryP2 if InitHigh==1 & period>3 & QuizBQuota==0 ,re vce(cluster SubjectID)
outreg2 using Table3alt2, tex
xtreg profit zurich GroupSize period Entry Quiz QuizXEntry Phase2 EntryP2 QuizP2  QuizXEntryP2  HighGroup HighXGroupSize HighXperiod HighXEntry HighXQuiz HighXQuizXEntry  if InitHigh==0 & period>3 & QuizBQuota==0 ,re vce(cluster SubjectID)
outreg2 using Table3alt2, tex
xtreg profit zurich GroupSize period Entry Quiz QuizXEntry  Phase2 EntryP2 QuizP2  QuizXEntryP2  if InitHigh==1 & period>3 & QuizBQuota==0 ,re vce(cluster SubjectID)
outreg2 using Table3alt2, tex


************
* with QBQ

xtreg public zurich GroupSize period Entry Quiz QuizXEntry QuizBQuota Phase2 EntryP2 QuizP2  QuizXEntryP2 QuizBQuotaP2 HighGroup HighXGroupSize HighXperiod HighXEntry HighXQuiz HighXQuizXEntry HighXQuizBQuota if InitHigh==0 & period>3,re vce(cluster SubjectID)
outreg2 using Table3alt3, word replace
outreg2 using Table3alt3t, tex replace

xtreg public zurich GroupSize period Entry Quiz QuizXEntry QuizBQuota Phase2 EntryP2 QuizP2  QuizXEntryP2 QuizBQuotaP2 if InitHigh==1 & period>3,re vce(cluster SubjectID)
outreg2 using Table3alt3, word 
outreg2 using Table3alt3t, tex

xtreg profit zurich GroupSize period Entry Quiz QuizXEntry QuizBQuota Phase2 EntryP2 QuizP2  QuizXEntryP2 QuizBQuotaP2 HighGroup HighXGroupSize HighXperiod HighXEntry HighXQuiz HighXQuizXEntry HighXQuizBQuota if InitHigh==0 & period>3,re vce(cluster SubjectID)
outreg2 using Table3alt3, word
outreg2 using Table3alt3t, tex 

xtreg profit zurich GroupSize period Entry Quiz QuizXEntry QuizBQuota Phase2 EntryP2 QuizP2  QuizXEntryP2 QuizBQuotaP2 if InitHigh==1 & period>3,re vce(cluster SubjectID)
outreg2 using Table3alt3, word
outreg2 using Table3alt3t, tex 


 





***********************************************************************************************************
***********************************************************************************************************


*******************************************************
* Begin Group Level Analysis
*******************************************************

gen FamPeriod=Family*1000+period
egen NumAttemptMoves=sum(attempt), by (FamPeriod)
egen SuccessMoves=sum(move), by (FamPeriod)

*this line drops all but one observation per group per period. Only group level analysis possible from this point on.
duplicates drop GroupPeriod, force
xtset GroupID period

****Group Level Data for Table 1
table treatment if period>3 & period<11 & HighGroup==0, c (mean MinPublic  mean GroupSize)
table treatment if period>15 & HighGroup==0, c (mean MinPublic  mean GroupSize) 

table treatment if period>3 & period<11 & HighGroup==1, c (mean MinPublic  mean GroupSize)
table treatment if period>15 & HighGroup==1, c (mean MinPublic  mean GroupSize) 

**** Data For Figure 1
table period treatment if period > 0 & HighGroup==1, c(mean MinPublic) 

**** Data for Figure 2
 table period treatment if period > 0 & HighGroup==1, c(mean GroupSize) 
 
 
 **** Data For Figure 3
 table period treatment if period >10 & HighGroup==1, c(mean NumAttemptMove)
 table period treatment if period >10 & HighGroup==1, c(mean SuccessMoves)
 
**** Table 2 
*min public data for the tests in table 2
bysort treatment: table period GroupID if  HighGroup==1, c(mean MinPublic )

***** Column 5 for Table 3
xtreg MinPublic GroupSize period  Entry Quiz QuizXEntry QuizBQuota Phase2  EntryP2 QuizP2  QuizXEntryP2 QuizBQuotaP2 if HighGroup==1 & period>3, re vce(cluster GroupID)


lincom EntryP2 - QuizP2
lincom EntryP2 - QuizXEntryP2
lincom QuizP2 - QuizXEntryP2

outreg2 using Table3Col5, tex replace

lincom Phase2+EntryP2
lincom Phase2+QuizP2
lincom Phase2+QuizXEntryP2
lincom Phase2+QuizBQuotaP2

**** Column 5 for Table 3a
xtreg MinPublic GroupSize period  Entry Quiz QuizXEntry Phase2  EntryP2 QuizP2  QuizXEntryP2 if HighGroup==1 & period>3 & treatment>1, re vce(cluster GroupID)
outreg2 using Table3aCol5, tex replace


xtreg MinPublic zurich GroupSize period  Entry Quiz QuizXEntry QuizBQuota Phase2  EntryP2 QuizP2  QuizXEntryP2 QuizBQuotaP2 if HighGroup==1 & period>3, re vce(cluster GroupID)
outreg2 using Table3alt3, word
outreg2 using Table3alt3t, tex 


*************** Wilcoxon Tests

use ".\WilcoxonTestData.dta", clear

**** original Table
ranksum IndivAvFirst if Treatment ==1 | Treatment==2, by (Treatment)
ranksum IndivAvFirst if Treatment ==1 | Treatment==3, by (Treatment)
ranksum IndivAvFirst if Treatment ==1 | Treatment==4, by (Treatment)
ranksum IndivAvFirst if Treatment ==1 | Treatment==5, by (Treatment)

ranksum IndivAvSecond if Treatment ==1 | Treatment==2, by (Treatment)
ranksum IndivAvSecond if Treatment ==1 | Treatment==3, by (Treatment)
ranksum IndivAvSecond if Treatment ==1 | Treatment==4, by (Treatment)
ranksum IndivAvSecond if Treatment ==1 | Treatment==5, by (Treatment)

ranksum GroupFirst if Treatment ==1 | Treatment==2, by (Treatment)
ranksum GroupFirst if Treatment ==1 | Treatment==3, by (Treatment)
ranksum GroupFirst if Treatment ==1 | Treatment==4, by (Treatment)
ranksum GroupFirst if Treatment ==1 | Treatment==5, by (Treatment)

ranksum GroupSecond if Treatment ==1 | Treatment==2, by (Treatment)
ranksum GroupSecond if Treatment ==1 | Treatment==3, by (Treatment)
ranksum GroupSecond if Treatment ==1 | Treatment==4, by (Treatment) 
ranksum GroupSecond if Treatment ==1 | Treatment==5, by (Treatment)

*** test of difference from QuizBQuota

ranksum IndivAvFirst if Treatment ==5 | Treatment==2, by (Treatment)
ranksum IndivAvFirst if Treatment ==5 | Treatment==3, by (Treatment)
ranksum IndivAvFirst if Treatment ==5 | Treatment==4, by (Treatment)


ranksum IndivAvSecond if Treatment ==5 | Treatment==2, by (Treatment)
ranksum IndivAvSecond if Treatment ==5 | Treatment==3, by (Treatment)
ranksum IndivAvSecond if Treatment ==5 | Treatment==4, by (Treatment)


ranksum GroupFirst if Treatment ==5 | Treatment==2, by (Treatment)
ranksum GroupFirst if Treatment ==5 | Treatment==3, by (Treatment)
ranksum GroupFirst if Treatment ==5 | Treatment==4, by (Treatment)


ranksum GroupSecond if Treatment ==5 | Treatment==2, by (Treatment)
ranksum GroupSecond if Treatment ==5 | Treatment==3, by (Treatment)
ranksum GroupSecond if Treatment ==5 | Treatment==4, by (Treatment)






log close
