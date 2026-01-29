import excel "data.xlsx", sheet("all") firstrow clear

//////////////////////////////////////////////////////////////////////////
/////////////////// Wilcoxon signed rank tests ///////////////////////////
//////////////////////////////////////////////////////////////////////////

////////// tests of significance of the type of opponent /////////////////

// playing A/B for player 1 (1 shot game: strangers vs teams)
// T1_BB = player 1 chooses BB (1) or something else (0) (as player 1 and player 2) when interacting with a teammate in simple coordination game
// S1_BB = player 1 chooses BB (1) or something else (0) (as player 1 and player 2) when interacting with a stranger in simple coordination game
summarize T1_BB S1_BB
signrank T1_BB = S1_BB

// T2_BB = player 1 chooses In+BB (1) or something else (0) (as player 1 and player 2) when interacting with a teammate in simple coordination game
// S2_BB = player 1 chooses In+BB (1) or something else (0) (as player 1 and player 2) when interacting with a stranger in simple coordination game
summarize T2_BB S2_BB
signrank T2_BB = S2_BB

//////////////////////////////////////////////////////////////////////////
//////////////////////// Mann-Whitney tests //////////////////////////////
//////////////////////////////////////////////////////////////////////////

//// Test of significance of high/low self/group connectedness on choosing (B,B) and (In,B,B) ////

summarize T1_BB
ranksum T1_BB, by(High_G)
summarize T1_BB
ranksum T1_BB, by(High_S)

summarize T2_BB
ranksum T2_BB, by(High_G)
summarize T2_BB
ranksum T2_BB, by(High_S)

///////////////////////////////////////////////////////
// compare behavior as player 1 versus player 2
// chi square test

// Table 15 in paper (appendix)
summarize S1_1_AB S1_2_AB
tabulate S1_1_AB S1_2_AB, chi2
summarize V1_1_AB V1_2_AB
tabulate V1_1_AB V1_2_AB, chi2
summarize T1_1_AB T1_2_AB
tabulate T1_1_AB T1_2_AB, chi2

// Table 16 in paper (appendix)
summarize S2_1_INAB S2_2_AB
tabulate S2_1_INAB S2_2_AB, chi2
summarize V2_1_INAB V2_2_AB
tabulate V2_1_INAB V2_2_AB, chi2
summarize T2_1_INAB T2_2_AB
tabulate T2_1_INAB T2_2_AB, chi2
