* This .do file allows to reproduce the tables of the 'resutls section' in its current order.
* Estimation have been run on Stata 13

* Table 2 - Ranking decisions
* Require EER-D-17-00428_data_ranking.dta

rologit rank samegrouprank, group(_indiv)
rologit rank samegrouprank if treatment_RankHom==1, group(_indiv)
rologit rank samegrouprank highcost if treatment_RankHet==1, group(_indiv)

* Table 3 - Wage-setting decision
* Require EER-D-17-00428_data_main.dta

xtlogit highwage samegroupworker treatment_rank samegrouprank treatment_het treatment_RankHet altruism  if employer==1
xtlogit highwage samegroupworker treatment_rank samegrouprank altruism  if employer==1 & treatment_hom==1
xtlogit highwage samegroupworker treatment_rank samegrouprank  highcostworker altruism  if employer==1 & treatment_het==1

* Table 4 - Worker Effort Choices
* Require EER-D-17-00428_data_main.dta

xttobit effort wage samegroupemployer samegroupworker treatment_rank if worker==1 , ll(1)
xttobit effort wage samegroupemployer samegroupworker treatment_rank wageother_above wageother_same lowcost if worker==1 , ll(1)
xttobit effort wage samegroupemployer samegroupworker treatment_rank wageother_above wageother_same lowcost wageingroupemployer if worker==1 , ll(1)
xttobit effort wage samegroupemployer samegroupworker treatment_rank wageother_above wageother_same lowcost wageingroupemployer altruism envy if worker==1 , ll(1)

* Table 5 - Money burning - Descriptive statistics
* Require EER-D-17-00428_data_unemployed.dta
* First column : total money burnt by treatment
egen temp=sum(cost_money_burning) , by(treatment)
tab treatment, sum(temp)
drop temp*
* Reparticion of money-burning between 'target burn' and 'burn all'
bysort treatment: sum burn_oncetarget burn_group

* Table 6 - Determinants of money burning
* Require EER-D-17-00428_data_unemployed.dta

xtlogit burn2 treatment_rank treatment_het treatment_RankHet statuttarget_employer gaintarget highcosttarget highcost lowcosthighcost samegrouptarget envy, vce(cluster _obsind)
xtlogit burn treatment_rank treatment_het treatment_RankHet statuttarget_employer gaintarget highcosttarget highcost lowcosthighcost samegrouptarget envy if line_burnall==0, vce(cluster _obsind)

* Table 7 - The cost for society of money burning
* Require EER-D-17-00428_data_main.dta

reg couts_money_burning treatment_rank treatment_het treatment_RankHet employer if unemployed==0 & _obs<3
reg couts_money_burning treatment_het employer  if _obs<3 & unemployed==0 & treatment_rank==0
reg couts_money_burning treatment_het employer  if _obs<3 & unemployed==0 & treatment_rank==1
reg couts_money_burning treatment_het employer discrim_society_bis if _obs<3 & unemployed==0 & treatment_rank==1

