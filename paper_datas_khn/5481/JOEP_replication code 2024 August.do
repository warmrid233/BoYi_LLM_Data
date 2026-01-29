********************************************
** The codes below are presented in accordance with the introduction order of the related table, figure, or appendix in the body
********************************************

clear

import delimited "data.csv"

gen subject_id = session*100 + subject

rename gender female
replace female=female-1

* to fix mis-input
replace female=1 if session==11 &subject==4  

gen additional_semester=.
replace additional_semester=0 if session<13
replace additional_semester=1 if session>=13
tab additional_semester

gen strong_instruction=0
replace strong_instruction=1 if session==13 | session==17 | session==18 |session==19 |session==20

* self_image
gen q1_rev=6-q1
gen q10_rev=6-q10
gen q11_rev=6-q11
gen self_image = (q1_rev + q2 + q3 + q4 + q5 + q6 + q7 + q8+ q9 + q10_rev + q11_rev - 11) /44
tab self_image

* gender identification
gen q14_rev=6-q14
gen q15_rev=6-q15
generate identification=(q12+q13+q14_rev+q15_rev-4)/16
tab identification

*** Agreement to  androcentric social norms
generate social_norms=(q16+q17+q18+q19-4)/16
tab social_norms

* stereotype of my gender
gen lazy_rev=6-lazy
gen impatient_rev=6-impatient
gen reckless_rev=6-reckless
gen stereo_mygender = (generous + lazy_rev + frugal + impatient_rev + studious + cautious + artistic + patient + reckless_rev - 9)/36
tab stereo_mygender

* risk_loving 
generate risk_loving=.
replace risk_loving=0 if part2_choice1==1& part2_choice2==1 & part2_choice3==1& part2_choice4==1 & part2_choice5==1& part2_choice6==1 & part2_choice7==1& part2_choice8==1 & part2_choice9==1& part2_choice10==1 &part2_choice11==1
replace risk_loving=1 if part2_choice1==1& part2_choice2==1 & part2_choice3==1& part2_choice4==1 & part2_choice5==1& part2_choice6==1 & part2_choice7==1& part2_choice8==1 & part2_choice9==1& part2_choice10==1 &part2_choice11==2
replace risk_loving=2 if part2_choice1==1& part2_choice2==1 & part2_choice3==1& part2_choice4==1 & part2_choice5==1& part2_choice6==1 & part2_choice7==1& part2_choice8==1 & part2_choice9==1& part2_choice10==2 &part2_choice11==2
replace risk_loving=3 if part2_choice1==1& part2_choice2==1 & part2_choice3==1& part2_choice4==1 & part2_choice5==1& part2_choice6==1 & part2_choice7==1& part2_choice8==1 & part2_choice9==2& part2_choice10==2 &part2_choice11==2
replace risk_loving=4 if part2_choice1==1& part2_choice2==1 & part2_choice3==1& part2_choice4==1 & part2_choice5==1& part2_choice6==1 & part2_choice7==1& part2_choice8==2 & part2_choice9==2& part2_choice10==2 &part2_choice11==2
replace risk_loving=5 if part2_choice1==1& part2_choice2==1 & part2_choice3==1& part2_choice4==1 & part2_choice5==1& part2_choice6==1 & part2_choice7==2& part2_choice8==2 & part2_choice9==2& part2_choice10==2 &part2_choice11==2
replace risk_loving=6 if part2_choice1==1& part2_choice2==1 & part2_choice3==1& part2_choice4==1 & part2_choice5==1& part2_choice6==2 & part2_choice7==2& part2_choice8==2 & part2_choice9==2& part2_choice10==2 &part2_choice11==2
replace risk_loving=7 if part2_choice1==1& part2_choice2==1 & part2_choice3==1& part2_choice4==1 & part2_choice5==2& part2_choice6==2 & part2_choice7==2& part2_choice8==2 & part2_choice9==2& part2_choice10==2 &part2_choice11==2
replace risk_loving=8 if part2_choice1==1& part2_choice2==1 & part2_choice3==1& part2_choice4==2 & part2_choice5==2& part2_choice6==2 & part2_choice7==2& part2_choice8==2 & part2_choice9==2& part2_choice10==2 &part2_choice11==2
replace risk_loving=9 if part2_choice1==1& part2_choice2==1 & part2_choice3==2& part2_choice4==2 & part2_choice5==2& part2_choice6==2 & part2_choice7==2& part2_choice8==2 & part2_choice9==2& part2_choice10==2 &part2_choice11==2
replace risk_loving=10 if part2_choice1==1& part2_choice2==2 & part2_choice3==2& part2_choice4==2 & part2_choice5==2& part2_choice6==2 & part2_choice7==2& part2_choice8==2 & part2_choice9==2& part2_choice10==2 &part2_choice11==2
replace risk_loving=11 if part2_choice1==2& part2_choice2==2 & part2_choice3==2& part2_choice4==2 & part2_choice5==2& part2_choice6==2 & part2_choice7==2& part2_choice8==2 & part2_choice9==2& part2_choice10==2 &part2_choice11==2
tab risk_loving female

* quiz answers
generate quiz1_correct=0
replace quiz1_correct=1 if quiz1==4
generate quiz2_correct=0
replace quiz2_correct=1 if quiz2==1
generate quiz3_correct=0
replace quiz3_correct=1 if quiz3==4
generate quiz4_correct=0
replace quiz4_correct=1 if quiz4==2
generate quiz5_correct=0
replace quiz5_correct=1 if quiz5==1
generate quiz6_correct=0
replace quiz6_correct=1 if quiz6==2
generate quiz7_correct=0
replace quiz7_correct=1 if quiz7==1
generate quiz8_correct=0
replace quiz8_correct=1 if quiz8==1
generate quiz_score=quiz1_correct+quiz2_correct+quiz3_correct+quiz4_correct+quiz5_correct+quiz6_correct+quiz7_correct+quiz8_correct
tab quiz_score



** Appendix B: summary statistics
global control "additional_semester strong_instruction num_subject year friend self_image identification social_norms stereo_mygender risk_loving quiz_score"
sum $control


*** Figure 2
** This figure was genereated using python. See "Python_code_for_Figure 2.html" for the code




 

* to make choice =1 to indicate risky choice (cooperation) and 0 to safe choice (defection)
replace choice_same_gender = 2 - choice_same_gender
replace choice_diff_gender = 2 - choice_diff_gender
replace choice_same_neutral = 2 - choice_same_neutral
replace choice_diff_neutral = 2 - choice_diff_neutral

rename choice_same_gender risky_choice1
rename choice_diff_gender risky_choice2
rename choice_same_neutral risky_choice3
rename choice_diff_neutral risky_choice4


** to long format
reshape long risky_choice, i(subject_id) j(type)
sort type
by type: sum risky_choice
rename type task_type
	
generate same_avatar=.
generate gender_avatar=.

replace same_avatar=1 if task_type==1 | task_type==3
replace same_avatar=0 if task_type==2 | task_type==4

replace gender_avatar=1 if task_type==1 |task_type==2
replace gender_avatar=0 if task_type==3 |task_type==4

tabulate play_order, generate(play_order)
tabulate session, generate(session)

sort session subject_id


generate round=.
replace round=1 if task_type==1 & play_order==1
replace round=2 if task_type==2 & play_order==1
replace round=3 if task_type==3 & play_order==1
replace round=4 if task_type==4 & play_order==1

replace round=1 if task_type==1 & play_order==2
replace round=2 if task_type==2 & play_order==2
replace round=3 if task_type==4 & play_order==2
replace round=4 if task_type==3 & play_order==2

replace round=1 if task_type==2 & play_order==3
replace round=2 if task_type==1 & play_order==3
replace round=3 if task_type==3 & play_order==3
replace round=4 if task_type==4 & play_order==3

replace round=1 if task_type==2 & play_order==4
replace round=2 if task_type==1 & play_order==4
replace round=3 if task_type==4 & play_order==4
replace round=4 if task_type==3 & play_order==4

replace round=1 if task_type==3 & play_order==5
replace round=2 if task_type==4 & play_order==5
replace round=3 if task_type==2 & play_order==5
replace round=4 if task_type==1 & play_order==5

replace round=1 if task_type==4 & play_order==6
replace round=2 if task_type==3 & play_order==6
replace round=3 if task_type==2 & play_order==6
replace round=4 if task_type==1 & play_order==6



*** Table 1
global control "additional_semester strong_instruction num_subject year friend self_image identification social_norms stereo_mygender risk_loving quiz_score"
xtset subject_id round

xtlogit risky_choice same_avatar gender_avatar female i.play_order
estimates store model1
margins, dydx(gender_avatar)

xtlogit risky_choice same_avatar gender_avatar female i.play_order $control
estimates store model2
margins, dydx(gender_avatar)

xtlogit risky_choice i.gender_avatar##i.same_avatar female i.play_order $control
estimates store model3
margins, dydx(same_avatar) at(gender_avatar=(0(1)1)) vsquish 

* among male
xtlogit risky_choice i.gender_avatar##i.same_avatar female i.play_order $control if female==0
estimates store model4
margins, dydx(same_avatar) at(gender_avatar=(0(1)1)) vsquish 

* among female
xtlogit risky_choice i.gender_avatar##i.same_avatar female i.play_order $control if female==1
estimates store model5
margins, dydx(same_avatar) at(gender_avatar=(0(1)1)) vsquish 



** Appendix D: The effect of strong instructions

xtlogit risky_choice same_avatar gender_avatar strong_instruction female i.play_order $control
estimates store str_inst_model1

xtlogit risky_choice i.same_avatar##i.strong_instruction i.gender_avatar##i.strong_instruction female i.play_order $control
estimates store str_inst_model2




** Appendix E: The effect of correct identification of avatars

gen female_avatar_correct = . 
replace female_avatar_correct = 0 if female_avatar == 1 | female_avatar == 3
replace female_avatar_correct = 1 if female_avatar == 2
tab female_avatar_correct

gen male_avatar_correct = . 
replace male_avatar_correct = 0 if male_avatar == 2 | male_avatar == 3
replace male_avatar_correct = 1 if male_avatar == 1
tab male_avatar_correct 

gen neutral_female_avatar_correct = .
replace neutral_female_avatar_correct = 0 if neutral_female_avatar == 1 | neutral_female_avatar == 2
replace neutral_female_avatar_correct = 1 if neutral_female_avatar == 3
tab neutral_female_avatar_correct

gen neutral_male_avatar_correct = .
replace neutral_male_avatar_correct = 0 if neutral_male_avatar == 1 | neutral_male_avatar == 2
replace neutral_male_avatar_correct = 1 if neutral_male_avatar == 3
tab neutral_male_avatar_correct

gen correct_guess_avatar = female_avatar_correct + male_avatar_correct + neutral_female_avatar_correct + neutral_male_avatar_correct
tab correct_guess_avatar

gen binary_correct_guess_avatar = 0
replace binary_correct_guess_avatar = 1 if female_avatar_correct == 1 & male_avatar_correct == 1 & neutral_female_avatar_correct == 1 & neutral_male_avatar_correct == 1
tab binary_correct_guess_avatar

xtlogit risky_choice same_avatar gender_avatar binary_correct_guess_avatar female i.play_order strong_instruction $control
estimates store ava_model1

xtlogit risky_choice i.same_avatar##i.binary_correct_guess_avatar i.gender_avatar##i.binary_correct_guess_avatar female i.play_order strong_instruction $control
estimates store ava_model2




** Appendix F: Experimenter demand effect

xtlogit risky_choice same_avatar gender_avatar exp_effect female i.play_order strong_instruction $control
estimates store exp_model1

xtlogit risky_choice i.same_avatar##i.exp_effect i.gender_avatar##i.exp_effect female i.play_order strong_instruction $control
estimates store exp_model2




** Appendix G: Heterogenous effects of same avatars according to Gender identification

xtlogit risky_choice i.same_avatar##c.identification i.gender_avatar##c.identification female i.play_order additional_semester strong_instruction num_subject year friend self_image social_norms stereo_mygender risk_loving quiz_score
estimates store model1
margins, dydx(same_avatar) at(identification=(0(0.1)1)) vsquish 
marginsplot, yline(0) xsize(3) ysize(4) graphregion(color(white)) title("Male and female participants together", color(black) size(medium)) xtitle("Gender identification") xscale(r(0 (0.1) 1)) ytitle("Effect on the probability of the risky choice") ylabel(-0.3(0.05)0.15) yscale(r(-0.3 (0.05) 0.15)) ci1opts(lc("gs0")) plot1opts(msymbol(O) mcolor("gs0") msize(medium)) saving(appendix_hetero_1, replace)


xtlogit risky_choice i.same_avatar##c.identification i.gender_avatar##c.identification i.play_order additional_semester strong_instruction num_subject year friend self_image social_norms stereo_mygender risk_loving quiz_score if female==0
estimates store model2
margins, dydx(same_avatar) at(identification=(0(0.1)1)) vsquish 
marginsplot, yline(0) xsize(3) ysize(4) graphregion(color(white)) title("Male participants only", color(black) size(medium)) xtitle("Gender identification") xscale(r(0 (0.1) 1)) ytitle("Effect on the probability of the risky choice") ylabel(-0.3(0.05)0.15) yscale(r(-0.3 (0.05) 0.15))ci1opts(lc("gs0")) plot1opts(msymbol(O) mcolor("gs0") msize(medium)) saving(appendix_hetero_2, replace)


xtlogit risky_choice i.same_avatar##c.identification i.gender_avatar##c.identification i.play_order additional_semester strong_instruction num_subject year friend self_image social_norms stereo_mygender risk_loving quiz_score if female==1
estimates store model3
margins, dydx(same_avatar) at(identification=(0(0.1)1)) vsquish 
marginsplot, yline(0) xsize(3) ysize(4) graphregion(color(white)) title("Female participants only", color(black) size(medium)) xtitle("Gender identification") xscale(r(0 (0.1) 1)) ytitle("Effect on the probability of the risky choice") ylabel(-0.3(0.05)0.15) yscale(r(-0.3 (0.05) 0.15))ci1opts(lc("gs0")) plot1opts(msymbol(O) mcolor("gs0") msize(medium)) saving(appendix_hetero_3, replace)

graph combine appendix_hetero_1.gph appendix_hetero_2.gph appendix_hetero_3.gph, col(3) graphregion(color(white))






** Appendix H: Heterogenous effects of same avatars according to Agreement to androcentric social norms

xtlogit risky_choice i.same_avatar##c.social_norms i.gender_avatar##c.social_norms female i.play_order additional_semester strong_instruction num_subject year friend self_image identification stereo_mygender risk_loving quiz_score
estimates store model1
margins, dydx(same_avatar) at(social_norms=(0(0.1)1)) vsquish 
marginsplot, yline(0) xsize(3) ysize(4) graphregion(color(white)) title("Male and female participants together", color(black) size(medium)) xtitle("Agreement to androcentric social norms") xscale(r(0 (0.1) 1)) ytitle("Effect on the probability of the risky choice") ylabel(-0.45(0.05)0.25) yscale(r(-0.45 (0.05) 0.25)) ci1opts(lc("gs0")) plot1opts(msymbol(O) mcolor("gs0") msize(medium)) saving(appendix_hetero_4, replace)

xtlogit risky_choice i.same_avatar##c.social_norms i.gender_avatar##c.social_norms i.play_order additional_semester strong_instruction num_subject year friend self_image identification stereo_mygender risk_loving quiz_score if female==0
estimates store model2
margins, dydx(same_avatar) at(social_norms=(0(0.1)1)) vsquish 
marginsplot, yline(0) xsize(3) ysize(4) graphregion(color(white)) title("Male participants only", color(black) size(medium)) xtitle("Agreement to androcentric social norms") xscale(r(0 (0.1) 1)) ytitle("Effect on the probability of the risky choice") ylabel(-0.45(0.05)0.25) yscale(r(-0.45 (0.05) 0.25)) ci1opts(lc("gs0")) plot1opts(msymbol(O) mcolor("gs0") msize(medium)) saving(appendix_hetero_5, replace)

xtlogit risky_choice i.same_avatar##c.social_norms i.gender_avatar##c.social_norms i.play_order additional_semester strong_instruction num_subject year friend self_image identification stereo_mygender risk_loving quiz_score if female==1
estimates store model3
margins, dydx(same_avatar) at(social_norms=(0(0.1)1)) vsquish 
marginsplot, yline(0) xsize(3) ysize(4) graphregion(color(white)) title("Female participants only", color(black) size(medium)) xtitle("Agreement to androcentric social norms") xscale(r(0 (0.1) 1)) ytitle("Effect on the probability of the risky choice") ylabel(-0.45(0.05)0.25) yscale(r(-0.45 (0.05) 0.25)) ci1opts(lc("gs0")) plot1opts(msymbol(O) mcolor("gs0") msize(medium)) saving(appendix_hetero_6, replace)

graph combine appendix_hetero_4.gph appendix_hetero_5.gph appendix_hetero_6.gph, col(3) graphregion(color(white))




** Appendix I: Heterogenous effects of same avatars according to Positive perception of my own gender group.

xtlogit risky_choice i.same_avatar##c.stereo_mygender i.gender_avatar##c.stereo_mygender female i.play_order additional_semester strong_instruction num_subject year friend self_image identification social_norms risk_loving quiz_score
estimates store model1
margins, dydx(same_avatar) at(stereo_mygender=(0(0.1)1)) vsquish 
marginsplot, yline(0) xsize(3) ysize(4) graphregion(color(white)) title("Male and female participants together", color(black) size(medium)) xtitle("Positive perception of my own gender group") xscale(r(0 (0.1) 1)) ytitle("Effect on the probability of the risky choice") ylabel(-0.55(0.05)0.25) yscale(r(-0.55 (0.05) 0.25)) ci1opts(lc("gs0")) plot1opts(msymbol(O) mcolor("gs0") msize(medium)) saving(appendix_hetero_7, replace)

xtlogit risky_choice i.same_avatar##c.stereo_mygender i.gender_avatar##c.stereo_mygender i.play_order additional_semester strong_instruction num_subject year friend self_image identification social_norms risk_loving quiz_score if female==0 
estimates store model2
margins, dydx(same_avatar) at(stereo_mygender=(0(0.1)1)) vsquish 
marginsplot, yline(0) xsize(3) ysize(4) graphregion(color(white)) title("Male participants only", color(black) size(medium)) xtitle("Positive perception of my own gender group") xscale(r(0 (0.1) 1)) ytitle("Effect on the probability of the risky choice") ylabel(-0.55(0.05)0.25) yscale(r(-0.55 (0.05) 0.25)) ci1opts(lc("gs0")) plot1opts(msymbol(O) mcolor("gs0") msize(medium)) saving(appendix_hetero_8, replace)

xtlogit risky_choice i.same_avatar##c.stereo_mygender i.gender_avatar##c.stereo_mygender i.play_order additional_semester strong_instruction num_subject year friend self_image identification social_norms risk_loving quiz_score if female==1
estimates store model3
margins, dydx(same_avatar) at(stereo_mygender=(0(0.1)1)) vsquish 
marginsplot, yline(0) xsize(3) ysize(4) graphregion(color(white)) title("Female participants only", color(black) size(medium)) xtitle("Positive perception of my own gender group") xscale(r(0 (0.1) 1)) ytitle("Effect on the probability of the risky choice") ylabel(-0.55(0.05)0.25) yscale(r(-0.55 (0.05) 0.25)) ci1opts(lc("gs0")) plot1opts(msymbol(O) mcolor("gs0") msize(medium)) saving(appendix_hetero_9, replace)

graph combine appendix_hetero_7.gph appendix_hetero_8.gph appendix_hetero_9.gph, col(3) graphregion(color(white))


