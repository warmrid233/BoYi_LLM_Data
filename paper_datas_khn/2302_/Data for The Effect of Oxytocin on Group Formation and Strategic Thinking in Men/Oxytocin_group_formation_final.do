
clear all

import excel using "/Users/Melos/Dropbox (ASU)/Oxytocin Working Paper/GroupFormation/Hormones and Behaviour/Second-Re-submission/Data/OT_group_formation.xlsx",  firstrow case(lower)


gen id=_n

// first test
tab  choice_group oxytocin, chi2

probit choice_group oxytocin
probit choice_group oxytocin c.guess_part1
probit choice_group oxytocin##c.guess_part1
margins , dydx(oxytocin) at( guess_part1=(14.9 36.64 58.4))

// convert from likert scale to actual percentages (winning chances)
replace  expectation_group_performance =  expectation_group_performance * 0.125
ttest expectation_group_performance , by(oxytocin)




// generate collapsed data set and delete mutiple group observations
generate a = (session*100) + (unit_part2*10) + group
sort a
by a: generate n1 = _n

drop if n1>1 & role ==1


gen reduction2 = log(guess_round2 / groupavg_round1)
gen reduction3 = log(guess_round3 / groupavg_round2)
gen reduction4 = log(guess_round4 / groupavg_round3)


reshape long guess_round groupavg_round  reduction  , i(id) j(round)
xtset id round

xttobit reduction oxytocin  ,    vce(bootstrap, reps(200))
xttobit reduction oxytocin role round  ,    vce(bootstrap, reps(200))




