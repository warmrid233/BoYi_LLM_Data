import excel "data.xlsx", sheet("all") firstrow clear

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

replace S1_1_AB=. if S1_1_AB==0
replace S1_2_AB=. if S1_2_AB==0
replace S1_1_AB=0 if S1_1_AB==1
replace S1_2_AB=0 if S1_2_AB==1
replace S1_1_AB=1 if S1_1_AB==2
replace S1_2_AB=1 if S1_2_AB==2

replace T2_2_AB=. if T2_2_AB==0
replace T2_2_AB=0 if T2_2_AB==1
replace T2_2_AB=1 if T2_2_AB==2

replace V2_2_AB=. if V2_2_AB==0
replace V2_2_AB=0 if V2_2_AB==1
replace V2_2_AB=1 if V2_2_AB==2

replace S2_2_AB=. if S2_2_AB==0
replace S2_2_AB=0 if S2_2_AB==1
replace S2_2_AB=1 if S2_2_AB==2

replace S2_1_INAB=. if S2_1_INAB==0
replace S2_1_INAB=0 if S2_1_INAB==1
replace S2_1_INAB=1 if S2_1_INAB==2
replace S2_1_INAB=2 if S2_1_INAB==3

replace V2_1_INAB=. if V2_1_INAB==0
replace V2_1_INAB=0 if V2_1_INAB==1
replace V2_1_INAB=1 if V2_1_INAB==2
replace V2_1_INAB=2 if V2_1_INAB==3

replace T2_1_INAB=. if T2_1_INAB==0
replace T2_1_INAB=0 if T2_1_INAB==1
replace T2_1_INAB=1 if T2_1_INAB==2
replace T2_1_INAB=2 if T2_1_INAB==3

//////////////////////////////////////////////////////////////////////////
/////////////////// Wilcoxon signed rank tests ///////////////////////////
//////////////////////////////////////////////////////////////////////////

////////// tests of significance of the type of opponent /////////////////

// Figure 2 and Table 4 in Paper

// playing A/B for player 1 (1 shot game: strangers vs teams)
// T1_1_AB = player 1's choice A/B when interacting with a teammate in simple coordination game
// S1_1_AB = player 1's choice A/B when interacting with a stranger in simple coordination game
summarize T1_1_AB S1_1_AB
signrank T1_1_AB = S1_1_AB

// playing A/B for player 1 (1 shot game: strangers vs club)
// V1_1_AB = player 1's choice A/B when interacting with a club player in simple coordination game
// S1_1_AB = player 1's choice A/B when interacting with a stranger in simple coordination game
summarize V1_1_AB S1_1_AB
signrank V1_1_AB = S1_1_AB

// playing A/B for player 1 (1 shot game: club vs teams)
// T1_1_AB = player 1's choice A/B when interacting with a teammate in simple coordination game
// V1_1_AB = player 1's choice A/B when interacting with a club player in simple coordination game
summarize T1_1_AB V1_1_AB
signrank T1_1_AB = V1_1_AB

// playing A/B for player 2 (1 shot game: strangers vs teams)
// T1_2_AB = player 2's choice A/B when interacting with a teammate in simple coordination game
// S1_2_AB = player 2's choice A/B when interacting with a stranger in simple coordination game
summarize T1_2_AB S1_2_AB
signrank T1_2_AB = S1_2_AB

// playing A/B for player 2 (1 shot game: strangers vs club)
// V1_2_AB = player 2's choice A/B when interacting with a club player in simple coordination game
// S1_2_AB = player 2's choice A/B when interacting with a stranger in simple coordination game
summarize V1_2_AB S1_2_AB
signrank V1_2_AB = S1_2_AB

// playing A/B for player 2 (1 shot game: club vs teams)
// T1_2_AB = player 2's choice A/B when interacting with a teammate in simple coordination game
// V1_2_AB = player 2's choice A/B when interacting with a club player in simple coordination game
summarize T1_2_AB V1_2_AB
signrank T1_2_AB = V1_2_AB

// Figure 3 and Table 7 in paper

// playing IN+B (binary) for player 1 (2 stage game: strangers vs teams)
// T2_1_INB = player 1's choice IN+B when interacting with a teammate in game with outside option
// S2_1_INB = player 1's choice IN+B when interacting with a stranger player in game with outside option
summarize T2_1_INB S2_1_INB
signrank T2_1_INB = S2_1_INB

// playing IN+B (binary) for player 1 (2 stage game: strangers vs club)
// V2_1_INB = player 1's choice IN+B when interacting with a club player in game with outside option
// S2_1_INB = player 1's choice IN+B when interacting with a stranger player in game with outside option
summarize V2_1_INB S2_1_INB
signrank V2_1_INB = S2_1_INB

// playing IN+B (binary) for player 1 (2 stage game: strangers vs teams)
// V2_1_INB = player 1's choice IN+B when interacting with a club player in game with outside option
// T2_1_INB = player 1's choice IN+B when interacting with a teammate in game with outside option
summarize T2_1_INB V2_1_INB
signrank T2_1_INB = V2_1_INB

// playing IN+A (binary) for player 1 (2 stage game: strangers vs teams)
// T2_1_INA = player 1's choice IN+A when interacting with a teammate in game with outside option
// S2_1_INA = player 1's choice IN+A when interacting with a stranger player in game with outside option
summarize T2_1_INA S2_1_INA
signrank T2_1_INA = S2_1_INA

// playing IN+A (binary) for player 1 (2 stage game: strangers vs club)
// V2_1_INA = player 1's choice IN+A when interacting with a club player in game with outside option
// S2_1_INA = player 1's choice IN+A when interacting with a stranger player in game with outside option
summarize V2_1_INA S2_1_INA
signrank V2_1_INA = S2_1_INA

// playing IN+A (binary) for player 1 (2 stage game: strangers vs club)
// V2_1_INA = player 1's choice IN+B when interacting with a club player in game with outside option
// S2_1_INA = player 1's choice IN+B when interacting with a stranger player in game with outside option
summarize T2_1_INA V2_1_INA
signrank T2_1_INA = V2_1_INA
