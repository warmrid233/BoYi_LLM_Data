***Tests using Centipede.dta***

IN TEXT (2.2 paragraph 1)
ranksum strategy, by(ingroup)

TABLE 1
ranksum belief1 if player==1, by(ingroup)
ranksum belief2 if player==1, by(ingroup)
ranksum belief3 if player==1, by(ingroup)
ranksum belief1 if player==2, by(ingroup)
ranksum belief2 if player==2, by(ingroup)
ranksum belief3 if player==2, by(ingroup)


***Tests using Centipede_Regressions.dta***

PROBIT REGRESSION TABLE (Centipede Game)
probit continue ingroup, cluster(subject)
probit continue i.ingroup belief, cluster(subject)
margins, dydx(belief) at(ingroup==0)  vsquish
margins, dydx(belief) at(ingroup==1)  vsquish
margins, dydx(ingroup) at(belief=(0(1)12)) vsquish
probit continue i.ingroup##c.belief, cluster(subject)
margins, dydx(belief) at(ingroup==0)  vsquish
margins, dydx(belief) at(ingroup==1)  vsquish
margins, dydx(ingroup) at(belief=(0(1)12)) vsquish


***Tests using StagHunt.dta***

IN TEXT (3.2 paragraph 2)
prtest BRUR, by(ingroup)

IN TEXT (3.2 paragraph 2)
tabulate game choice if ingroup==1, exact
tabulate game choice if ingroup==0, exact

IN TEXT (3.2 paragraph 5)
ranksum distance_uniform, by(ingroup)
ranksum BRURbelief, by(ingroup)
ranksum beliefL, by(ingroup)
ranksum beliefR, by(ingroup)


PROBIT REGRESSION TABLE (Stag Hunt Game)
probit BRUR ingroup
probit BRUR i.ingroup BRURbelief
margins, dydx(BRURbelief) at(ingroup==0)  vsquish
margins, dydx(BRURbelief) at(ingroup==1)  vsquish
margins, dydx(ingroup) at(BRURbelief=(0(10)100)) vsquish
probit BRUR i.ingroup##c.BRURbelief
margins, dydx(BRURbelief) at(ingroup==0)  vsquish
margins, dydx(BRURbelief) at(ingroup==1)  vsquish
margins, dydx(ingroup) at(BRURbelief=(0(10)100)) vsquish