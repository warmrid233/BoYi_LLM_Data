////////////////////////////////////////////////////////////////////////////
// analysis for subjects with high relative group connectedness ////////////
////////////////////////////////////////////////////////////////////////////

import excel "data.xlsx", sheet("highG") firstrow clear

replace S1_1_AB=. if S1_1_AB==0
replace S1_2_AB=. if S1_2_AB==0
replace S1_1_AB=0 if S1_1_AB==1
replace S1_2_AB=0 if S1_2_AB==1
replace S1_1_AB=1 if S1_1_AB==2
replace S1_2_AB=1 if S1_2_AB==2

replace T1_1_AB=. if T1_1_AB==0
replace T1_2_AB=. if T1_2_AB==0
replace T1_1_AB=0 if T1_1_AB==1
replace T1_2_AB=0 if T1_2_AB==1
replace T1_1_AB=1 if T1_1_AB==2
replace T1_2_AB=1 if T1_2_AB==2

replace V1_1_AB=. if V1_1_AB==0
replace V1_2_AB=. if V1_2_AB==0
replace V1_1_AB=0 if V1_1_AB==1
replace V1_2_AB=0 if V1_2_AB==1
replace V1_1_AB=1 if V1_1_AB==2
replace V1_2_AB=1 if V1_2_AB==2

replace T2_2_AB=. if T2_2_AB==0
replace S2_2_AB=. if S2_2_AB==0
replace V2_2_AB=. if V2_2_AB==0
replace T2_2_AB=0 if T2_2_AB==1
replace S2_2_AB=0 if S2_2_AB==1
replace V2_2_AB=0 if V2_2_AB==1
replace T2_2_AB=1 if T2_2_AB==2
replace S2_2_AB=1 if S2_2_AB==2
replace V2_2_AB=1 if V2_2_AB==2

// playing A/B for player 1 (1 shot game: strangers vs teams)
// T1_1_AB = player 1's choice A/B when interacting with a teammate in simple coordination game
// V1_1_AB = player 1's choice A/B when interacting with a club member in simple coordination game
// S1_1_AB = player 1's choice A/B when interacting with a stranger in simple coordination game
// Figure 4 and Table 6 in paper
summarize T1_1_AB V1_1_AB S1_1_AB

// playing A/B for player 2 (1 shot game: strangers vs teams)
// T1_2_AB = player 2's choice A/B when interacting with a teammate in simple coordination game
// V1_2_AB = player 2's choice A/B when interacting with a club member in simple coordination game
// S1_2_AB = player 2's choice A/B when interacting with a stranger in simple coordination game
// Table 6 in paper
summarize T1_2_AB V1_2_AB S1_2_AB

// playing IN+B for player 1 (2 stage game: strangers vs teams)
// T2_1_INB = player 1's choice IN+B when interacting with a teammate in simple coordination game
// V2_1_INB = player 1's choice IN+B when interacting with a club member in simple coordination game
// S2_1_INB = player 1's choice IN+B when interacting with a stranger in simple coordination game
// Figure 5 and Table 11 in paper
summarize T2_1_INB V2_1_INB S2_1_INB

// playing A/B for player 2 (2 stage game: strangers vs teams)
// T2_2_AB = player 2's choice A/B when interacting with a teammate in 2 stage coordination game
// V2_2_AB = player 2's choice A/B when interacting with a club member in 2 stage coordination game
// S2_2_AB = player 2's choice A/B when interacting with a stranger in 2 stage coordination game
// Figure 6 and Table 12 in paper
summarize T2_2_AB V2_2_AB S2_2_AB

////////////////////////////////////////////////////////////////////////////
// analysis for subjects with low relative group connectedness ////////////
////////////////////////////////////////////////////////////////////////////
import excel "data.xlsx", sheet("lowG") firstrow clear

replace S1_1_AB=. if S1_1_AB==0
replace S1_2_AB=. if S1_2_AB==0
replace S1_1_AB=0 if S1_1_AB==1
replace S1_2_AB=0 if S1_2_AB==1
replace S1_1_AB=1 if S1_1_AB==2
replace S1_2_AB=1 if S1_2_AB==2

replace T1_1_AB=. if T1_1_AB==0
replace T1_2_AB=. if T1_2_AB==0
replace T1_1_AB=0 if T1_1_AB==1
replace T1_2_AB=0 if T1_2_AB==1
replace T1_1_AB=1 if T1_1_AB==2
replace T1_2_AB=1 if T1_2_AB==2

replace V1_1_AB=. if V1_1_AB==0
replace V1_2_AB=. if V1_2_AB==0
replace V1_1_AB=0 if V1_1_AB==1
replace V1_2_AB=0 if V1_2_AB==1
replace V1_1_AB=1 if V1_1_AB==2
replace V1_2_AB=1 if V1_2_AB==2

replace T2_2_AB=. if T2_2_AB==0
replace S2_2_AB=. if S2_2_AB==0
replace V2_2_AB=. if V2_2_AB==0
replace T2_2_AB=0 if T2_2_AB==1
replace S2_2_AB=0 if S2_2_AB==1
replace V2_2_AB=0 if V2_2_AB==1
replace T2_2_AB=1 if T2_2_AB==2
replace S2_2_AB=1 if S2_2_AB==2
replace V2_2_AB=1 if V2_2_AB==2

// playing A/B for player 1 (1 shot game: strangers vs teams)
// T1_1_AB = player 1's choice A/B when interacting with a teammate in simple coordination game
// V1_1_AB = player 1's choice A/B when interacting with a club member in simple coordination game
// S1_1_AB = player 1's choice A/B when interacting with a stranger in simple coordination game
// Figure 4 and Table 6 in paper
summarize T1_1_AB V1_1_AB S1_1_AB

// playing A/B for player 2 (1 shot game: strangers vs teams)
// T1_2_AB = player 2's choice A/B when interacting with a teammate in simple coordination game
// V1_2_AB = player 2's choice A/B when interacting with a club member in simple coordination game
// S1_2_AB = player 2's choice A/B when interacting with a stranger in simple coordination game
// Table 6 in paper
summarize T1_2_AB V1_2_AB S1_2_AB

// playing IN+B for player 1 (2 stage game: strangers vs teams)
// T2_1_INB = player 1's choice IN+B when interacting with a teammate in simple coordination game
// V2_1_INB = player 1's choice IN+B when interacting with a club member in simple coordination game
// S2_1_INB = player 1's choice IN+B when interacting with a stranger in simple coordination game
// Figure 5 and Table 11 in paper
summarize T2_1_INB V2_1_INB S2_1_INB

// playing A/B for player 2 (2 stage game: strangers vs teams)
// T2_2_AB = player 2's choice A/B when interacting with a teammate in 2 stage coordination game
// V2_2_AB = player 2's choice A/B when interacting with a club member in 2 stage coordination game
// S2_2_AB = player 2's choice A/B when interacting with a stranger in 2 stage coordination game
// Figure 6 and Table 12 in paper
summarize T2_2_AB V2_2_AB S2_2_AB

////////////////////////////////////////////////////////////////////////////
// analysis for subjects with high relative self connectedness ////////////
////////////////////////////////////////////////////////////////////////////

import excel "data.xlsx", sheet("highS") firstrow clear

replace S1_1_AB=. if S1_1_AB==0
replace S1_2_AB=. if S1_2_AB==0
replace S1_1_AB=0 if S1_1_AB==1
replace S1_2_AB=0 if S1_2_AB==1
replace S1_1_AB=1 if S1_1_AB==2
replace S1_2_AB=1 if S1_2_AB==2

replace T1_1_AB=. if T1_1_AB==0
replace T1_2_AB=. if T1_2_AB==0
replace T1_1_AB=0 if T1_1_AB==1
replace T1_2_AB=0 if T1_2_AB==1
replace T1_1_AB=1 if T1_1_AB==2
replace T1_2_AB=1 if T1_2_AB==2

replace V1_1_AB=. if V1_1_AB==0
replace V1_2_AB=. if V1_2_AB==0
replace V1_1_AB=0 if V1_1_AB==1
replace V1_2_AB=0 if V1_2_AB==1
replace V1_1_AB=1 if V1_1_AB==2
replace V1_2_AB=1 if V1_2_AB==2

replace T2_2_AB=. if T2_2_AB==0
replace S2_2_AB=. if S2_2_AB==0
replace V2_2_AB=. if V2_2_AB==0
replace T2_2_AB=0 if T2_2_AB==1
replace S2_2_AB=0 if S2_2_AB==1
replace V2_2_AB=0 if V2_2_AB==1
replace T2_2_AB=1 if T2_2_AB==2
replace S2_2_AB=1 if S2_2_AB==2
replace V2_2_AB=1 if V2_2_AB==2

// playing A/B for player 1 (1 shot game: strangers vs teams)
// T1_1_AB = player 1's choice A/B when interacting with a teammate in simple coordination game
// V1_1_AB = player 1's choice A/B when interacting with a club member in simple coordination game
// S1_1_AB = player 1's choice A/B when interacting with a stranger in simple coordination game
// Figure 4 and Table 5 in paper
summarize T1_1_AB V1_1_AB S1_1_AB

// playing A/B for player 2 (1 shot game: strangers vs teams)
// T1_2_AB = player 2's choice A/B when interacting with a teammate in simple coordination game
// V1_2_AB = player 2's choice A/B when interacting with a club member in simple coordination game
// S1_2_AB = player 2's choice A/B when interacting with a stranger in simple coordination game
// Table 5 in paper
summarize T1_2_AB V1_2_AB S1_2_AB

// playing IN+B for player 1 (2 stage game: strangers vs teams)
// T2_1_INB = player 1's choice IN+B when interacting with a teammate in simple coordination game
// V2_1_INB = player 1's choice IN+B when interacting with a club member in simple coordination game
// S2_1_INB = player 1's choice IN+B when interacting with a stranger in simple coordination game
// Figure 5 and Table 9 in paper
summarize T2_1_INB V2_1_INB S2_1_INB

// playing A/B for player 2 (2 stage game: strangers vs teams)
// T2_2_AB = player 2's choice A/B when interacting with a teammate in 2 stage coordination game
// V2_2_AB = player 2's choice A/B when interacting with a club member in 2 stage coordination game
// S2_2_AB = player 2's choice A/B when interacting with a stranger in 2 stage coordination game
// Figure 6 and Table 10 in paper
summarize T2_2_AB V2_2_AB S2_2_AB

////////////////////////////////////////////////////////////////////////////
// analysis for subjects with low relative self connectedness ////////////
////////////////////////////////////////////////////////////////////////////
import excel "data.xlsx", sheet("lowS") firstrow clear

replace S1_1_AB=. if S1_1_AB==0
replace S1_2_AB=. if S1_2_AB==0
replace S1_1_AB=0 if S1_1_AB==1
replace S1_2_AB=0 if S1_2_AB==1
replace S1_1_AB=1 if S1_1_AB==2
replace S1_2_AB=1 if S1_2_AB==2

replace T1_1_AB=. if T1_1_AB==0
replace T1_2_AB=. if T1_2_AB==0
replace T1_1_AB=0 if T1_1_AB==1
replace T1_2_AB=0 if T1_2_AB==1
replace T1_1_AB=1 if T1_1_AB==2
replace T1_2_AB=1 if T1_2_AB==2

replace V1_1_AB=. if V1_1_AB==0
replace V1_2_AB=. if V1_2_AB==0
replace V1_1_AB=0 if V1_1_AB==1
replace V1_2_AB=0 if V1_2_AB==1
replace V1_1_AB=1 if V1_1_AB==2
replace V1_2_AB=1 if V1_2_AB==2

replace T2_2_AB=. if T2_2_AB==0
replace S2_2_AB=. if S2_2_AB==0
replace V2_2_AB=. if V2_2_AB==0
replace T2_2_AB=0 if T2_2_AB==1
replace S2_2_AB=0 if S2_2_AB==1
replace V2_2_AB=0 if V2_2_AB==1
replace T2_2_AB=1 if T2_2_AB==2
replace S2_2_AB=1 if S2_2_AB==2
replace V2_2_AB=1 if V2_2_AB==2

// playing A/B for player 1 (1 shot game: strangers vs teams)
// T1_1_AB = player 1's choice A/B when interacting with a teammate in simple coordination game
// V1_1_AB = player 1's choice A/B when interacting with a club member in simple coordination game
// S1_1_AB = player 1's choice A/B when interacting with a stranger in simple coordination game
// Figure 4 in paper
summarize T1_1_AB V1_1_AB S1_1_AB

// playing A/B for player 2 (1 shot game: strangers vs teams)
// T1_2_AB = player 2's choice A/B when interacting with a teammate in simple coordination game
// V1_2_AB = player 2's choice A/B when interacting with a club member in simple coordination game
// S1_2_AB = player 2's choice A/B when interacting with a stranger in simple coordination game
summarize T1_2_AB V1_2_AB S1_2_AB

// playing IN+B for player 1 (2 stage game: strangers vs teams)
// T2_1_INB = player 1's choice IN+B when interacting with a teammate in simple coordination game
// V2_1_INB = player 1's choice IN+B when interacting with a club member in simple coordination game
// S2_1_INB = player 1's choice IN+B when interacting with a stranger in simple coordination game
// Figure 5 in paper
summarize T2_1_INB V2_1_INB S2_1_INB

// playing A/B for player 2 (2 stage game: strangers vs teams)
// T2_2_AB = player 2's choice A/B when interacting with a teammate in 2 stage coordination game
// V2_2_AB = player 2's choice A/B when interacting with a club member in 2 stage coordination game
// S2_2_AB = player 2's choice A/B when interacting with a stranger in 2 stage coordination game
// Figure 6 in paper
summarize T2_2_AB V2_2_AB S2_2_AB

/////////////////////////////////////////////////////////////////////////////////
import excel "data.xlsx", sheet("all") firstrow clear

// Pearson's Chi square test (Section 5.2 in paper)
tabulate High_G High_S, chi2

//////////////////////////////////////////////////////////////////////////
//////////////////////// Mann-Whitney tests //////////////////////////////
//////////////////////////////////////////////////////////////////////////

//// Test of significance of high/low group connectedness ////

// Figure 4 and Table 6 in paper
summarize T1_1_AB
ranksum T1_1_AB, by(High_G)
summarize V1_1_AB
ranksum V1_1_AB, by(High_G)
summarize S1_1_AB
ranksum S1_1_AB, by(High_G)

// Figure 5 and Table 11 in paper
summarize T2_1_INB
ranksum T2_1_INB, by(High_G)
summarize V2_1_INB
ranksum V2_1_INB, by(High_G)
summarize S2_1_INB
ranksum S2_1_INB, by(High_G)

// Figure 6 and Table 12 in paper
summarize T2_2_AB
ranksum T2_2_AB, by(High_G)
summarize V2_2_AB
ranksum V2_2_AB, by(High_G)
summarize S2_2_AB
ranksum S2_2_AB, by(High_G)

// Table 5 in paper
summarize T1_2_AB
ranksum T1_2_AB, by(High_G)
summarize V1_2_AB
ranksum V1_2_AB, by(High_G)
summarize S1_2_AB
ranksum S1_2_AB, by(High_G)

//// Test of significance of high/low self connectedness////

// Figure 4 and Table 5 in paper
summarize T1_1_AB
ranksum T1_1_AB, by(High_S)
summarize V1_1_AB
ranksum V1_1_AB, by(High_S)
summarize S1_1_AB
ranksum S1_1_AB, by(High_S)

// Figure 5 and Table 9 in paper
summarize T2_1_INB
ranksum T2_1_INB, by(High_S)
summarize V2_1_INB
ranksum V2_1_INB, by(High_S)
summarize S2_1_INB
ranksum S2_1_INB, by(High_S)

// Figure 6 and Table 10 in paper
summarize T2_2_AB
ranksum T2_2_AB, by(High_S)
summarize V2_2_AB
ranksum V2_2_AB, by(High_S)
summarize S2_2_AB
ranksum S2_2_AB, by(High_S)

// Table 5 in paper
summarize T1_2_AB
ranksum T1_2_AB, by(High_S)
summarize V1_2_AB
ranksum V1_2_AB, by(High_S)
summarize S1_2_AB
ranksum S1_2_AB, by(High_S)

// not reported in paper
summarize T2_1_IN
ranksum T2_1_IN, by(High_S)
summarize V2_1_IN
ranksum V2_1_IN, by(High_S)
summarize S2_1_IN
ranksum S2_1_IN, by(High_S)
