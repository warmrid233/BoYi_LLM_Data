
/*******************************************************************************************
File:        analysis_sumstat.do
Authors:     Priyoma Mustafi and Ritwik Banerjee
Paper:       Using social recognition to address the gender difference in volunteering 
             for low-promotability tasks
Last edit:   5/26/2025

Description: Take cleaned data, presents all decsriptive stats, for full and phase wise data

*********************************************************************************************/


use "$replication/data/master.dta" , clear 



*------------------------------------------------------------------------------------*
* Table 1: Descriptive stats for all variables and test of significances- (fulldata) *
*------------------------------------------------------------------------------------* 


/* Define variable lists */
local outcome_vars "n_invest_subject group_success1"
local control_vars "share_females_session" 
local behavioral_vars "altruism num_safe non_conformity agreeableness"  
local demographic_vars "age female caste religion fam_inc_category student"

/* Create matrix to store results */
local nrows = 13  // 2 outcomes + 1 control + 4 behavioral + 6 demographic variables
local ncols = 5   // Baseline + 4 treatments

matrix results = J(`nrows', `ncols', .)
matrix colnames results = Baseline Treatment2 Treatment3 Treatment4 BaselineR
matrix rownames results = TotalInvestment GroupInvestment FemaleSessionShare Altruism Risk NonConformity Agreeableness Age Female Caste Religion MonthlyFamilyIncome YearInCollege

/* Create matrices for sample sizes */
matrix sessions = J(1, 5, .)
matrix subjects = J(1, 5, .)

/* Create matrix for significance indicators */
matrix significance = J(`nrows', `ncols', 0)

/* Generate statistics */
save "$replication/temp.dta", replace 

keep if period == 1

// /* Create treatment dummy variables */
// forvalues i=2/5 {
//     gen t`i'_t1 = . 
//     replace t`i'_t1 = 1 if treatment == `i'
//     replace t`i'_t1 = 0 if treatment == 1
// }

/* Total Investment (n_invest_subject) - Row 1 - Use t-test */
/* Calculate means for total investment */
forvalues treat = 1/5 {
    summarize n_invest_subject if treatment == `treat'
    matrix results[1, `treat'] = r(mean)
}

/* Test significance for total investment using t-test */
forvalues i = 2/5 {
    ttest n_invest_subject, by(t`i'_t1)
    if r(p) < 0.01 {
        matrix significance[1, `i'] = 3
    }
    else if r(p) < 0.05 {
        matrix significance[1, `i'] = 2
    }
    else if r(p) < 0.10 {
        matrix significance[1, `i'] = 1
    }
}

/* Group Investment (Group Success) - Row 2 - Use Fisher's exact test */
/* First collapse to group level for group success */

use "$replication/temp.dta", clear


/* Now collapse */
collapse group_success1, by(treatment phase session_id group period)
egen unique_group = group(group period)

forvalues i=2/5 {
    gen t`i'_t1 = . 
    replace t`i'_t1 = 1 if treatment == `i'
    replace t`i'_t1 = 0 if treatment == 1
}

/* Calculate means for group success */
forvalues treat = 1/5 {
    summarize group_success1 if treatment == `treat' & period!=11
    matrix results[2, `treat'] = r(mean)
}

/* Test significance for group success using Fisher's exact test */
forvalues i = 2/5 {
    tab group_success1 t`i'_t1 , exact
    if r(p_exact) < 0.01 {
        matrix significance[2, `i'] = 3
    }
    else if r(p_exact) < 0.05 {
        matrix significance[2, `i'] = 2
    }
    else if r(p_exact) < 0.10 {
        matrix significance[2, `i'] = 1
    }
}

matrix list results

/* Restore original data for other variables */
use "$replication/temp.dta", clear


drop if period == 11
collapse share_females_session, by(treatment phase session_id)

forvalues i=2/5 {
    gen t`i'_t1 = . 
    replace t`i'_t1 = 1 if treatment == `i'
    replace t`i'_t1 = 0 if treatment == 1
}

/* Calculate means for female session share */
forvalues treat = 1/5 {
    summarize share_females_session if treatment == `treat'
    matrix results[3, `treat'] = r(mean)
}

matrix list results

/* Test significance for female session share using Wilcoxon rank-sum test */
forvalues i = 2/4 {
    ranksum share_females_session, by(t`i'_t1)
    if r(p) < 0.01 {
        matrix significance[3, `i'] = 3
    }
    else if r(p) < 0.05 {
        matrix significance[3, `i'] = 2
    }
    else if r(p) < 0.10 {
        matrix significance[3, `i'] = 1
    }
}
matrix list results

/* Restore for remaining variables */
use "$replication/temp.dta", clear
keep if period == 1
local row = 4

/* Behavioral Variables (Rows 4-7) - Use t-test */
foreach var in altruism num_safe non_conformity agreeableness {
    /* Baseline (Treatment 1) */
    summarize `var' if treatment == 1
    matrix results[`row',1] = r(mean)
    
    /* Treatments 2-4 with significance tests */
    forvalues treat = 2/4 {
        summarize `var' if treatment == `treat'
        matrix results[`row',`treat'] = r(mean)
        
        /* Use t-test for behavioral variables */
        ttest `var', by(t`treat'_t1)
        if r(p) < 0.01 {
            matrix significance[`row',`treat'] = 3
        }
        else if r(p) < 0.05 {
            matrix significance[`row',`treat'] = 2
        }
        else if r(p) < 0.10 {
            matrix significance[`row',`treat'] = 1
        }
    }
    
    /* Baseline-R (Treatment 5) */
    summarize `var' if treatment == 5
    matrix results[`row',5] = r(mean)
    
    local row = `row' + 1
}

/* Demographic Variables (Rows 8-13) */
local demo_vars "age female caste religion fam_inc_category student"
foreach var in `demo_vars' {
    /* Baseline (Treatment 1) */
    summarize `var' if treatment == 1
    matrix results[`row',1] = r(mean)
    
    /* Treatments 2-4 with significance tests */
    forvalues treat = 2/4 {
        summarize `var' if treatment == `treat'
        matrix results[`row',`treat'] = r(mean)
        
        /* Use appropriate test based on variable type */
        if "`var'" == "age" | "`var'" == "female" | "`var'" == "student" {
            /* Use t-test for age, female, and student (year in college) */
            ttest `var', by(t`treat'_t1)
            if r(p) < 0.01 {
                matrix significance[`row',`treat'] = 3
            }
            else if r(p) < 0.05 {
                matrix significance[`row',`treat'] = 2
            }
            else if r(p) < 0.10 {
                matrix significance[`row',`treat'] = 1
            }
        }
        else if "`var'" == "caste" | "`var'" == "religion" | "`var'" == "fam_inc_category" {
            /* Use Fisher's exact test for caste, religion, and family income */
            tab `var' t`treat'_t1, exact
            if r(p_exact) < 0.01 {
                matrix significance[`row',`treat'] = 3
            }
            else if r(p_exact) < 0.05 {
                matrix significance[`row',`treat'] = 2
            }
            else if r(p_exact) < 0.10 {
                matrix significance[`row',`treat'] = 1
            }
        }
    }
    
    /* Baseline-R (Treatment 5) */
    summarize `var' if treatment == 5
    matrix results[`row',5] = r(mean)
    
    local row = `row' + 1
}

/* Sample size calculations */
/* Count sessions */
forvalues treat = 1/5 {
    quietly tab session_id if treatment == `treat'
    matrix sessions[1, `treat'] = r(r)
}

/* Count subjects */
forvalues treat = 1/5 {
    quietly count if treatment == `treat'
    matrix subjects[1, `treat'] = r(N)
}

matrix list results


/* Export to Excel with formatting */
putexcel set "$replication/tables/Table1.xlsx", replace

/* Write headers */
putexcel A1 = "Variable"
putexcel B1 = "Description" 
putexcel C1 = "Baseline"
putexcel D1 = "Treatment ☺"
putexcel E1 = "Treatment ☹"  
putexcel F1 = "Treatment ☺☹"
putexcel G1 = "Baseline-R"

/* Write section headers */
putexcel A2 = "Outcome"
putexcel A5 = "Control Variables"
putexcel A7 = "Behavioral Control Variables"
putexcel A12 = "Demographic Control Variables"
putexcel A19 = "Sample Size"

/* Write variable names and descriptions */
putexcel A3 = "TotalInvestment"
putexcel B3 = "Number of times one invests [0,10]"

putexcel A4 = "GroupInvestment"
putexcel B4 = "=1 if someone from the group invested in a round"

putexcel A6 = "Female Session Share"
putexcel B6 = "Share of females in session"

putexcel A8 = "Altruism"
putexcel B8 = "Index based on helping others and community"

putexcel A9 = "Risk"
putexcel B9 = "Safe choices in Holt and Laury risk game"

putexcel A10 = "Non-Conformity"
putexcel B10 = "Index based on how one deals with differing opinions"

putexcel A11 = "Agreeableness"
putexcel B11 = "Index based how considerate, aloof, rude, cooperative, forgiving and helpful, etc one perceives themself to be"

putexcel A13 = "Age"
putexcel B13 = "in years"

putexcel A14 = "Female"
putexcel B14 = "=1 if subject is female"

putexcel A15 = "Caste"
putexcel B15 = "=1 if General, =2 if SC , =3 if ST, 4 if OBC, 5 if Prefer not to say"

putexcel A16 = "Religion"
putexcel B16 = "=1 if Hindu, =2 if Muslim, = 3 if Christian, =4 if Others"

putexcel A17 = "Monthly Family Income"
putexcel B17 = "=1 if EWS, =2 if LIG, =3 if MIG, =4 if HIG, =5 if Rich, =6 if Super Rich"

putexcel A18 = "Year in College"
putexcel B18 = "Year in college [1,5]"

putexcel A20 = "Sessions"
putexcel A21 = "Subjects"

/* Write the data with significance indicators */
/* TotalInvestment - row 3 */
forvalues col = 1/5 {
    local value = results[1, `col']
    local sig_level = significance[1, `col']
    
    local formatted_value = string(`value', "%9.2f")
    
    if `sig_level' == 1 {
        local formatted_value = "`formatted_value'*"
    }
    else if `sig_level' == 2 {
        local formatted_value = "`formatted_value'**"  
    }
    else if `sig_level' == 3 {
        local formatted_value = "`formatted_value'***"
    }
    
    if `col' == 1 {
        putexcel C3 = "`formatted_value'"
    }
    else if `col' == 2 {
        putexcel D3 = "`formatted_value'"
    }
    else if `col' == 3 {
        putexcel E3 = "`formatted_value'"
    }
    else if `col' == 4 {
        putexcel F3 = "`formatted_value'"
    }
    else if `col' == 5 {
        putexcel G3 = "`formatted_value'"
    }
}

/* GroupInvestment - row 4 */
forvalues col = 1/5 {
    local value = results[2, `col']
    local sig_level = significance[2, `col']
    
    local formatted_value = string(`value', "%9.2f")
    
    if `sig_level' == 1 {
        local formatted_value = "`formatted_value'*"
    }
    else if `sig_level' == 2 {
        local formatted_value = "`formatted_value'**"  
    }
    else if `sig_level' == 3 {
        local formatted_value = "`formatted_value'***"
    }
    
    if `col' == 1 {
        putexcel C4 = "`formatted_value'"
    }
    else if `col' == 2 {
        putexcel D4 = "`formatted_value'"
    }
    else if `col' == 3 {
        putexcel E4 = "`formatted_value'"
    }
    else if `col' == 4 {
        putexcel F4 = "`formatted_value'"
    }
    else if `col' == 5 {
        putexcel G4 = "`formatted_value'"
    }
}

/* Control variables - row 6 */
forvalues col = 1/5 {
    local value = results[3, `col']
    local sig_level = significance[3, `col']
    
    local formatted_value = string(`value', "%9.2f")
    
    if `sig_level' == 1 {
        local formatted_value = "`formatted_value'*"
    }
    else if `sig_level' == 2 {
        local formatted_value = "`formatted_value'**"  
    }
    else if `sig_level' == 3 {
        local formatted_value = "`formatted_value'***"
    }
    
    if `col' == 1 {
        putexcel C6 = "`formatted_value'"
    }
    else if `col' == 2 {
        putexcel D6 = "`formatted_value'"
    }
    else if `col' == 3 {
        putexcel E6 = "`formatted_value'"
    }
    else if `col' == 4 {
        putexcel F6 = "`formatted_value'"
    }
    else if `col' == 5 {
        putexcel G6 = "`formatted_value'"
    }
}

/* Behavioral variables - rows 8-11 */
forvalues matrix_row = 4/7 {
    local excel_row = `matrix_row' + 4
    
    forvalues col = 1/5 {
        local value = results[`matrix_row', `col']
        local sig_level = significance[`matrix_row', `col']
        
        local formatted_value = string(`value', "%9.2f")
        
        if `sig_level' == 1 {
            local formatted_value = "`formatted_value'*"
        }
        else if `sig_level' == 2 {
            local formatted_value = "`formatted_value'**"  
        }
        else if `sig_level' == 3 {
            local formatted_value = "`formatted_value'***"
        }
        
        if `col' == 1 {
            putexcel C`excel_row' = "`formatted_value'"
        }
        else if `col' == 2 {
            putexcel D`excel_row' = "`formatted_value'"
        }
        else if `col' == 3 {
            putexcel E`excel_row' = "`formatted_value'"
        }
        else if `col' == 4 {
            putexcel F`excel_row' = "`formatted_value'"
        }
        else if `col' == 5 {
            putexcel G`excel_row' = "`formatted_value'"
        }
    }
}

/* Demographic variables - rows 13-18 */
forvalues matrix_row = 8/13 {
    local excel_row = `matrix_row' + 5
    
    forvalues col = 1/5 {
        local value = results[`matrix_row', `col']
        local sig_level = significance[`matrix_row', `col']
        
        local formatted_value = string(`value', "%9.2f")
        
        if `sig_level' == 1 {
            local formatted_value = "`formatted_value'*"
        }
        else if `sig_level' == 2 {
            local formatted_value = "`formatted_value'**"  
        }
        else if `sig_level' == 3 {
            local formatted_value = "`formatted_value'***"
        }
        
        if `col' == 1 {
            putexcel C`excel_row' = "`formatted_value'"
        }
        else if `col' == 2 {
            putexcel D`excel_row' = "`formatted_value'"
        }
        else if `col' == 3 {
            putexcel E`excel_row' = "`formatted_value'"
        }
        else if `col' == 4 {
            putexcel F`excel_row' = "`formatted_value'"
        }
        else if `col' == 5 {
            putexcel G`excel_row' = "`formatted_value'"
        }
    }
}

/* Write sample sizes */
forvalues col = 1/5 {
    local sessions_val = sessions[1, `col']
    local subjects_val = subjects[1, `col']
    
    if `col' == 1 {
        putexcel C20 = "`sessions_val'"
        putexcel C21 = "`subjects_val'"
    }
    else if `col' == 2 {
        putexcel D20 = "`sessions_val'"
        putexcel D21 = "`subjects_val'"
    }
    else if `col' == 3 {
        putexcel E20 = "`sessions_val'"
        putexcel E21 = "`subjects_val'"
    }
    else if `col' == 4 {
        putexcel F20 = "`sessions_val'"
        putexcel F21 = "`subjects_val'"
    }
    else if `col' == 5 {
        putexcel G20 = "`sessions_val'"
        putexcel G21 = "`subjects_val'"
    }
}

/* Apply formatting */
putexcel A1:G21, border(all)
putexcel A1:G1, bold
putexcel A2:A21, bold
putexcel C1:G1, hcenter
putexcel C3:G21, hcenter

display "Table exported to $replication/tables/Table1.xlsx"
display "Statistical tests used:"
display "- TotalInvestment (n_invest_subject): t-test"
display "- GroupInvestment (group_success1): Fisher's exact test"
display "- Female Session Share: Wilcoxon rank-sum test"
display "- Behavioral variables (altruism, num_safe, non_conformity, agreeableness): t-test"
display "- Age, Female, Year in College: t-test"
display "- Caste, Religion, Family Income: Fisher's exact test"
display "Significance levels: * p<0.10, ** p<0.05, *** p<0.01"



erase "$replication/temp.dta"



*---------------------------------------------------------------------------------------*
* Table A1: Descriptive stats for all variables and test of significances- (phase1data) *
*---------------------------------------------------------------------------------------* 
use "$replication/data/master.dta" , clear 


/* Define variable lists */
local outcome_vars "n_invest_subject group_success1"
local control_vars "share_females_session" 
local behavioral_vars "altruism num_safe non_conformity agreeableness"  
local demographic_vars "age female caste religion fam_inc_category student"

/* Create matrix to store results - only 4 treatments for phase 1 */
local nrows = 13  // 2 outcomes + 1 control + 4 behavioral + 6 demographic variables
local ncols = 4   // Only 4 treatments in phase 1

matrix results = J(`nrows', `ncols', .)
matrix colnames results = Baseline Treatment2 Treatment3 Treatment4
matrix rownames results = TotalInvestment GroupInvestment FemaleSessionShare Altruism Risk NonConformity Agreeableness Age Female Caste Religion MonthlyFamilyIncome YearInCollege

/* Create matrices for sample sizes */
matrix sessions = J(1, 4, .)
matrix subjects = J(1, 4, .)

/* Create matrix for significance indicators */
matrix significance = J(`nrows', `ncols', 0)

/* Generate statistics */
keep if phase==1
save "$replication/temp1.dta", replace 

keep if period == 1

/* Total Investment (n_invest_subject) - Row 1 - Use t-test */
/* Calculate means for total investment */
forvalues treat = 1/4 {
    summarize n_invest_subject if treatment == `treat'
    matrix results[1, `treat'] = r(mean)
}

/* Test significance for total investment using t-test */
forvalues i = 2/4 {
    ttest n_invest_subject, by(t`i'_t1)
    if r(p) < 0.01 {
        matrix significance[1, `i'] = 3
    }
    else if r(p) < 0.05 {
        matrix significance[1, `i'] = 2
    }
    else if r(p) < 0.10 {
        matrix significance[1, `i'] = 1
    }
}

/* Group Investment (Group Success) - Row 2 - Use Fisher's exact test */
/* First collapse to group level for group success */

use "$replication/temp1.dta", clear

/* Now collapse */
collapse group_success1, by(treatment phase session_id group period t2_t1 t3_t1 t4_t1)
egen unique_group = group(group period)

/* Calculate means for group success */
forvalues treat = 1/4 {
    summarize group_success1 if treatment == `treat'  & period!=11
    matrix results[2, `treat'] = r(mean)
}

/* Test significance for group success using Fisher's exact test */
forvalues i = 2/4 {
    tab group_success1 t`i'_t1 , exact
    if r(p_exact) < 0.01 {
        matrix significance[2, `i'] = 3
    }
    else if r(p_exact) < 0.05 {
        matrix significance[2, `i'] = 2
    }
    else if r(p_exact) < 0.10 {
        matrix significance[2, `i'] = 1
    }
}

matrix list results

/* Restore original data for other variables */
use "$replication/temp1.dta", clear

drop if period == 11
collapse share_females_session, by(treatment phase session_id)

forvalues i=2/4 {
    gen t`i'_t1 = . 
    replace t`i'_t1 = 1 if treatment == `i'
    replace t`i'_t1 = 0 if treatment == 1
}

/* Calculate means for female session share */
forvalues treat = 1/4 {
    summarize share_females_session if treatment == `treat' 
    matrix results[3, `treat'] = r(mean)
}

matrix list results

/* Test significance for female session share using Wilcoxon rank-sum test */
forvalues i = 2/4 {
    ranksum share_females_session, by(t`i'_t1)
    if r(p) < 0.01 {
        matrix significance[3, `i'] = 3
    }
    else if r(p) < 0.05 {
        matrix significance[3, `i'] = 2
    }
    else if r(p) < 0.10 {
        matrix significance[3, `i'] = 1
    }
}
matrix list results

/* Restore for remaining variables */
use "$replication/temp1.dta", clear
keep if period == 1
local row = 4

/* Behavioral Variables (Rows 4-7) - Use t-test */
foreach var in altruism num_safe non_conformity agreeableness {
    /* Baseline (Treatment 1) */
    summarize `var' if treatment == 1
    matrix results[`row',1] = r(mean)
    
    /* Treatments 2-4 with significance tests */
    forvalues treat = 2/4 {
        summarize `var' if treatment == `treat'
        matrix results[`row',`treat'] = r(mean)
        
        /* Use t-test for behavioral variables */
        ttest `var', by(t`treat'_t1)
        if r(p) < 0.01 {
            matrix significance[`row',`treat'] = 3
        }
        else if r(p) < 0.05 {
            matrix significance[`row',`treat'] = 2
        }
        else if r(p) < 0.10 {
            matrix significance[`row',`treat'] = 1
        }
    }
    
    local row = `row' + 1
}

/* Demographic Variables (Rows 8-13) */
local demo_vars "age female caste religion fam_inc_category student"
foreach var in `demo_vars' {
    /* Baseline (Treatment 1) */
    summarize `var' if treatment == 1
    matrix results[`row',1] = r(mean)
    
    /* Treatments 2-4 with significance tests */
    forvalues treat = 2/4 {
        summarize `var' if treatment == `treat'
        matrix results[`row',`treat'] = r(mean)
        
        /* Use appropriate test based on variable type */
        if "`var'" == "age" | "`var'" == "female" | "`var'" == "student" {
            /* Use t-test for age, female, and student (year in college) */
            ttest `var', by(t`treat'_t1)
            if r(p) < 0.01 {
                matrix significance[`row',`treat'] = 3
            }
            else if r(p) < 0.05 {
                matrix significance[`row',`treat'] = 2
            }
            else if r(p) < 0.10 {
                matrix significance[`row',`treat'] = 1
            }
        }
        else if "`var'" == "caste" | "`var'" == "religion" | "`var'" == "fam_inc_category" {
            /* Use Fisher's exact test for caste, religion, and family income */
            tab `var' t`treat'_t1, exact
            if r(p_exact) < 0.01 {
                matrix significance[`row',`treat'] = 3
            }
            else if r(p_exact) < 0.05 {
                matrix significance[`row',`treat'] = 2
            }
            else if r(p_exact) < 0.10 {
                matrix significance[`row',`treat'] = 1
            }
        }
    }
    
    local row = `row' + 1
}

/* Sample size calculations */
/* Count sessions */
forvalues treat = 1/4 {
    quietly tab session_id if treatment == `treat'
    matrix sessions[1, `treat'] = r(r)
}

/* Count subjects */
forvalues treat = 1/4 {
    quietly count if treatment == `treat'
    matrix subjects[1, `treat'] = r(N)
}

matrix list results

/* Export to Excel with formatting - removed description column */
putexcel set "$replication/tables/TableA1.xlsx", replace

/* Write headers - no description column */
putexcel A1 = "Variable"
putexcel B1 = "Baseline"
putexcel C1 = "Treatment ☺"
putexcel D1 = "Treatment ☹"  
putexcel E1 = "Treatment ☺☹"

/* Write section headers */
putexcel A2 = "Outcome"
putexcel A5 = "Control Variables"
putexcel A7 = "Behavioral Control Variables"
putexcel A12 = "Demographic Control Variables"
putexcel A19 = "Sample Size"

/* Write variable names */
putexcel A3 = "TotalInvestment"
putexcel A4 = "GroupInvestment"
putexcel A6 = "Female Session Share"
putexcel A8 = "Altruism"
putexcel A9 = "Risk"
putexcel A10 = "Non-Conformity"
putexcel A11 = "Agreeableness"
putexcel A13 = "Age"
putexcel A14 = "Female"
putexcel A15 = "Caste"
putexcel A16 = "Religion"
putexcel A17 = "Monthly Family Income"
putexcel A18 = "Year in College"
putexcel A20 = "Sessions"
putexcel A21 = "Subjects"

/* Write the data with significance indicators */
/* TotalInvestment - row 3 */
forvalues col = 1/4 {
    local value = results[1, `col']
    local sig_level = significance[1, `col']
    
    local formatted_value = string(`value', "%9.2f")
    
    if `sig_level' == 1 {
        local formatted_value = "`formatted_value'*"
    }
    else if `sig_level' == 2 {
        local formatted_value = "`formatted_value'**"  
    }
    else if `sig_level' == 3 {
        local formatted_value = "`formatted_value'***"
    }
    
    if `col' == 1 {
        putexcel B3 = "`formatted_value'"
    }
    else if `col' == 2 {
        putexcel C3 = "`formatted_value'"
    }
    else if `col' == 3 {
        putexcel D3 = "`formatted_value'"
    }
    else if `col' == 4 {
        putexcel E3 = "`formatted_value'"
    }
}

/* GroupInvestment - row 4 */
forvalues col = 1/4 {
    local value = results[2, `col']
    local sig_level = significance[2, `col']
    
    local formatted_value = string(`value', "%9.2f")
    
    if `sig_level' == 1 {
        local formatted_value = "`formatted_value'*"
    }
    else if `sig_level' == 2 {
        local formatted_value = "`formatted_value'**"  
    }
    else if `sig_level' == 3 {
        local formatted_value = "`formatted_value'***"
    }
    
    if `col' == 1 {
        putexcel B4 = "`formatted_value'"
    }
    else if `col' == 2 {
        putexcel C4 = "`formatted_value'"
    }
    else if `col' == 3 {
        putexcel D4 = "`formatted_value'"
    }
    else if `col' == 4 {
        putexcel E4 = "`formatted_value'"
    }
}

/* Control variables - row 6 */
forvalues col = 1/4 {
    local value = results[3, `col']
    local sig_level = significance[3, `col']
    
    local formatted_value = string(`value', "%9.2f")
    
    if `sig_level' == 1 {
        local formatted_value = "`formatted_value'*"
    }
    else if `sig_level' == 2 {
        local formatted_value = "`formatted_value'**"  
    }
    else if `sig_level' == 3 {
        local formatted_value = "`formatted_value'***"
    }
    
    if `col' == 1 {
        putexcel B6 = "`formatted_value'"
    }
    else if `col' == 2 {
        putexcel C6 = "`formatted_value'"
    }
    else if `col' == 3 {
        putexcel D6 = "`formatted_value'"
    }
    else if `col' == 4 {
        putexcel E6 = "`formatted_value'"
    }
}

/* Behavioral variables - rows 8-11 */
forvalues matrix_row = 4/7 {
    local excel_row = `matrix_row' + 4
    
    forvalues col = 1/4 {
        local value = results[`matrix_row', `col']
        local sig_level = significance[`matrix_row', `col']
        
        local formatted_value = string(`value', "%9.2f")
        
        if `sig_level' == 1 {
            local formatted_value = "`formatted_value'*"
        }
        else if `sig_level' == 2 {
            local formatted_value = "`formatted_value'**"  
        }
        else if `sig_level' == 3 {
            local formatted_value = "`formatted_value'***"
        }
        
        if `col' == 1 {
            putexcel B`excel_row' = "`formatted_value'"
        }
        else if `col' == 2 {
            putexcel C`excel_row' = "`formatted_value'"
        }
        else if `col' == 3 {
            putexcel D`excel_row' = "`formatted_value'"
        }
        else if `col' == 4 {
            putexcel E`excel_row' = "`formatted_value'"
        }
    }
}

/* Demographic variables - rows 13-18 */
forvalues matrix_row = 8/13 {
    local excel_row = `matrix_row' + 5
    
    forvalues col = 1/4 {
        local value = results[`matrix_row', `col']
        local sig_level = significance[`matrix_row', `col']
        
        local formatted_value = string(`value', "%9.2f")
        
        if `sig_level' == 1 {
            local formatted_value = "`formatted_value'*"
        }
        else if `sig_level' == 2 {
            local formatted_value = "`formatted_value'**"  
        }
        else if `sig_level' == 3 {
            local formatted_value = "`formatted_value'***"
        }
        
        if `col' == 1 {
            putexcel B`excel_row' = "`formatted_value'"
        }
        else if `col' == 2 {
            putexcel C`excel_row' = "`formatted_value'"
        }
        else if `col' == 3 {
            putexcel D`excel_row' = "`formatted_value'"
        }
        else if `col' == 4 {
            putexcel E`excel_row' = "`formatted_value'"
        }
    }
}

/* Write sample sizes */
forvalues col = 1/4 {
    local sessions_val = sessions[1, `col']
    local subjects_val = subjects[1, `col']
    
    if `col' == 1 {
        putexcel B20 = "`sessions_val'"
        putexcel B21 = "`subjects_val'"
    }
    else if `col' == 2 {
        putexcel C20 = "`sessions_val'"
        putexcel C21 = "`subjects_val'"
    }
    else if `col' == 3 {
        putexcel D20 = "`sessions_val'"
        putexcel D21 = "`subjects_val'"
    }
    else if `col' == 4 {
        putexcel E20 = "`sessions_val'"
        putexcel E21 = "`subjects_val'"
    }
}

/* Apply formatting */
putexcel A1:E21, border(all)
putexcel A1:E1, bold
putexcel A2:A21, bold
putexcel B1:E1, hcenter
putexcel B3:E21, hcenter

display "Table exported to $replication/tables/TableA1.xlsx"
display "Statistical tests used:"
display "- TotalInvestment (n_invest_subject): t-test"
display "- GroupInvestment (group_success1): Fisher's exact test"
display "- Female Session Share: Wilcoxon rank-sum test"
display "- Behavioral variables (altruism, num_safe, non_conformity, agreeableness): t-test"
display "- Age, Female, Year in College: t-test"
display "- Caste, Religion, Family Income: Fisher's exact test"
display "Significance levels: * p<0.10, ** p<0.05, *** p<0.01"

erase "$replication/temp1.dta"


*---------------------------------------------------------------------------------------*
* Table A2: Descriptive stats for all variables and test of significances- (phase2data) *
*---------------------------------------------------------------------------------------* 
use "$replication/data/master.dta" , clear 


/* Define variable lists */
local outcome_vars "n_invest_subject group_success1"
local control_vars "share_females_session" 
local behavioral_vars "altruism num_safe non_conformity agreeableness"  
local demographic_vars "age female caste religion fam_inc_category student"

/* Create matrix to store results */
local nrows = 13  // 2 outcomes + 1 control + 4 behavioral + 6 demographic variables
local ncols = 5   // Baseline + 4 treatments

matrix results = J(`nrows', `ncols', .)
matrix colnames results = Baseline Treatment2 Treatment3 Treatment4 BaselineR
matrix rownames results = TotalInvestment GroupInvestment FemaleSessionShare Altruism Risk NonConformity Agreeableness Age Female Caste Religion MonthlyFamilyIncome YearInCollege

/* Create matrices for sample sizes */
matrix sessions = J(1, 5, .)
matrix subjects = J(1, 5, .)

/* Create matrix for significance indicators */
matrix significance = J(`nrows', `ncols', 0)

/* Generate statistics */
keep if phase==2
save "$replication/temp2.dta", replace 

keep if period == 1

// /* Create treatment dummy variables */
// forvalues i=2/5 {
//     gen t`i'_t1 = . 
//     replace t`i'_t1 = 1 if treatment == `i'
//     replace t`i'_t1 = 0 if treatment == 1
// }

/* Total Investment (n_invest_subject) - Row 1 - Use t-test */
/* Calculate means for total investment */
forvalues treat = 1/5 {
    summarize n_invest_subject if treatment == `treat'
    matrix results[1, `treat'] = r(mean)
}

/* Test significance for total investment using t-test */
forvalues i = 2/5 {
    ttest n_invest_subject, by(t`i'_t1)
    if r(p) < 0.01 {
        matrix significance[1, `i'] = 3
    }
    else if r(p) < 0.05 {
        matrix significance[1, `i'] = 2
    }
    else if r(p) < 0.10 {
        matrix significance[1, `i'] = 1
    }
}

/* Group Investment (Group Success) - Row 2 - Use Fisher's exact test */
/* First collapse to group level for group success */

use "$replication/temp2.dta", clear


/* Now collapse */
collapse group_success1, by(treatment phase session_id group period t2_t1 t3_t1 t4_t1 t5_t1)
egen unique_group = group(group period)


/* Calculate means for group success */
forvalues treat = 1/5 {
    summarize group_success1 if treatment == `treat' & period!= 11 
    matrix results[2, `treat'] = r(mean)
}

/* Test significance for group success using Fisher's exact test */
forvalues i = 2/5 {
    tab group_success1 t`i'_t1 , exact
    if r(p_exact) < 0.01 {
        matrix significance[2, `i'] = 3
    }
    else if r(p_exact) < 0.05 {
        matrix significance[2, `i'] = 2
    }
    else if r(p_exact) < 0.10 {
        matrix significance[2, `i'] = 1
    }
}

matrix list results

/* Restore original data for other variables */
use "$replication/temp2.dta", clear


drop if period == 11
collapse share_females_session, by(treatment phase session_id)

forvalues i=2/5 {
    gen t`i'_t1 = . 
    replace t`i'_t1 = 1 if treatment == `i'
    replace t`i'_t1 = 0 if treatment == 1
}

/* Calculate means for female session share */
forvalues treat = 1/5 {
    summarize share_females_session if treatment == `treat'
    matrix results[3, `treat'] = r(mean)
}

matrix list results

/* Test significance for female session share using Wilcoxon rank-sum test */
forvalues i = 2/4 {
    ranksum share_females_session, by(t`i'_t1)
    if r(p) < 0.01 {
        matrix significance[3, `i'] = 3
    }
    else if r(p) < 0.05 {
        matrix significance[3, `i'] = 2
    }
    else if r(p) < 0.10 {
        matrix significance[3, `i'] = 1
    }
}
matrix list results

/* Restore for remaining variables */
use "$replication/temp2.dta", clear
keep if period == 1
local row = 4

/* Behavioral Variables (Rows 4-7) - Use t-test */
foreach var in altruism num_safe non_conformity agreeableness {
    /* Baseline (Treatment 1) */
    summarize `var' if treatment == 1
    matrix results[`row',1] = r(mean)
    
    /* Treatments 2-4 with significance tests */
    forvalues treat = 2/4 {
        summarize `var' if treatment == `treat'
        matrix results[`row',`treat'] = r(mean)
        
        /* Use t-test for behavioral variables */
        ttest `var', by(t`treat'_t1)
        if r(p) < 0.01 {
            matrix significance[`row',`treat'] = 3
        }
        else if r(p) < 0.05 {
            matrix significance[`row',`treat'] = 2
        }
        else if r(p) < 0.10 {
            matrix significance[`row',`treat'] = 1
        }
    }
    
    /* Baseline-R (Treatment 5) */
    summarize `var' if treatment == 5
    matrix results[`row',5] = r(mean)
    
    local row = `row' + 1
}

/* Demographic Variables (Rows 8-13) */
local demo_vars "age female caste religion fam_inc_category student"
foreach var in `demo_vars' {
    /* Baseline (Treatment 1) */
    summarize `var' if treatment == 1
    matrix results[`row',1] = r(mean)
    
    /* Treatments 2-4 with significance tests */
    forvalues treat = 2/4 {
        summarize `var' if treatment == `treat'
        matrix results[`row',`treat'] = r(mean)
        
        /* Use appropriate test based on variable type */
        if "`var'" == "age" | "`var'" == "female" | "`var'" == "student" {
            /* Use t-test for age, female, and student (year in college) */
            ttest `var', by(t`treat'_t1)
            if r(p) < 0.01 {
                matrix significance[`row',`treat'] = 3
            }
            else if r(p) < 0.05 {
                matrix significance[`row',`treat'] = 2
            }
            else if r(p) < 0.10 {
                matrix significance[`row',`treat'] = 1
            }
        }
        else if "`var'" == "caste" | "`var'" == "religion" | "`var'" == "fam_inc_category" {
            /* Use Fisher's exact test for caste, religion, and family income */
            tab `var' t`treat'_t1, exact
            if r(p_exact) < 0.01 {
                matrix significance[`row',`treat'] = 3
            }
            else if r(p_exact) < 0.05 {
                matrix significance[`row',`treat'] = 2
            }
            else if r(p_exact) < 0.10 {
                matrix significance[`row',`treat'] = 1
            }
        }
    }
    
    /* Baseline-R (Treatment 5) */
    summarize `var' if treatment == 5
    matrix results[`row',5] = r(mean)
    
    local row = `row' + 1
}

/* Sample size calculations */
/* Count sessions */
forvalues treat = 1/5 {
    quietly tab session_id if treatment == `treat'
    matrix sessions[1, `treat'] = r(r)
}

/* Count subjects */
forvalues treat = 1/5 {
    quietly count if treatment == `treat'
    matrix subjects[1, `treat'] = r(N)
}

matrix list results


/* Export to Excel with formatting */
putexcel set "$replication/tables/TableA2.xlsx", replace

/* Write headers */
putexcel A1 = "Variable"
putexcel B1 = "Baseline"
putexcel C1 = "Treatment ☺"
putexcel D1 = "Treatment ☹"  
putexcel E1 = "Treatment ☺☹"
putexcel F1 = "Baseline-R"

/* Write section headers */
putexcel A2 = "Outcome"
putexcel A5 = "Control Variables"
putexcel A7 = "Behavioral Control Variables"
putexcel A12 = "Demographic Control Variables"
putexcel A19 = "Sample Size"

/* Write variable names */
putexcel A3 = "TotalInvestment"
putexcel A4 = "GroupInvestment"
putexcel A6 = "Female Session Share"
putexcel A8 = "Altruism"
putexcel A9 = "Risk"
putexcel A10 = "Non-Conformity"
putexcel A11 = "Agreeableness"
putexcel A13 = "Age"
putexcel A14 = "Female"
putexcel A15 = "Caste"
putexcel A16 = "Religion"
putexcel A17 = "Monthly Family Income"
putexcel A18 = "Year in College"
putexcel A20 = "Sessions"
putexcel A21 = "Subjects"

/* Write the data with significance indicators */
/* TotalInvestment - row 3 */
forvalues col = 1/5 {
    local value = results[1, `col']
    local sig_level = significance[1, `col']
    
    local formatted_value = string(`value', "%9.2f")
    
    if `sig_level' == 1 {
        local formatted_value = "`formatted_value'*"
    }
    else if `sig_level' == 2 {
        local formatted_value = "`formatted_value'**"  
    }
    else if `sig_level' == 3 {
        local formatted_value = "`formatted_value'***"
    }
    
    if `col' == 1 {
        putexcel B3 = "`formatted_value'"
    }
    else if `col' == 2 {
        putexcel C3 = "`formatted_value'"
    }
    else if `col' == 3 {
        putexcel D3 = "`formatted_value'"
    }
    else if `col' == 4 {
        putexcel E3 = "`formatted_value'"
    }
    else if `col' == 5 {
        putexcel F3 = "`formatted_value'"
    }
}

/* GroupInvestment - row 4 */
forvalues col = 1/5 {
    local value = results[2, `col']
    local sig_level = significance[2, `col']
    
    local formatted_value = string(`value', "%9.2f")
    
    if `sig_level' == 1 {
        local formatted_value = "`formatted_value'*"
    }
    else if `sig_level' == 2 {
        local formatted_value = "`formatted_value'**"  
    }
    else if `sig_level' == 3 {
        local formatted_value = "`formatted_value'***"
    }
    
    if `col' == 1 {
        putexcel B4 = "`formatted_value'"
    }
    else if `col' == 2 {
        putexcel C4 = "`formatted_value'"
    }
    else if `col' == 3 {
        putexcel D4 = "`formatted_value'"
    }
    else if `col' == 4 {
        putexcel E4 = "`formatted_value'"
    }
    else if `col' == 5 {
        putexcel F4 = "`formatted_value'"
    }
}

/* Control variables - row 6 */
forvalues col = 1/5 {
    local value = results[3, `col']
    local sig_level = significance[3, `col']
    
    local formatted_value = string(`value', "%9.2f")
    
    if `sig_level' == 1 {
        local formatted_value = "`formatted_value'*"
    }
    else if `sig_level' == 2 {
        local formatted_value = "`formatted_value'**"  
    }
    else if `sig_level' == 3 {
        local formatted_value = "`formatted_value'***"
    }
    
    if `col' == 1 {
        putexcel B6 = "`formatted_value'"
    }
    else if `col' == 2 {
        putexcel C6 = "`formatted_value'"
    }
    else if `col' == 3 {
        putexcel D6 = "`formatted_value'"
    }
    else if `col' == 4 {
        putexcel E6 = "`formatted_value'"
    }
    else if `col' == 5 {
        putexcel F6 = "`formatted_value'"
    }
}

/* Behavioral variables - rows 8-11 */
forvalues matrix_row = 4/7 {
    local excel_row = `matrix_row' + 4
    
    forvalues col = 1/5 {
        local value = results[`matrix_row', `col']
        local sig_level = significance[`matrix_row', `col']
        
        local formatted_value = string(`value', "%9.2f")
        
        if `sig_level' == 1 {
            local formatted_value = "`formatted_value'*"
        }
        else if `sig_level' == 2 {
            local formatted_value = "`formatted_value'**"  
        }
        else if `sig_level' == 3 {
            local formatted_value = "`formatted_value'***"
        }
        
        if `col' == 1 {
            putexcel B`excel_row' = "`formatted_value'"
        }
        else if `col' == 2 {
            putexcel C`excel_row' = "`formatted_value'"
        }
        else if `col' == 3 {
            putexcel D`excel_row' = "`formatted_value'"
        }
        else if `col' == 4 {
            putexcel E`excel_row' = "`formatted_value'"
        }
        else if `col' == 5 {
            putexcel F`excel_row' = "`formatted_value'"
        }
    }
}

/* Demographic variables - rows 13-18 */
forvalues matrix_row = 8/13 {
    local excel_row = `matrix_row' + 5
    
    forvalues col = 1/5 {
        local value = results[`matrix_row', `col']
        local sig_level = significance[`matrix_row', `col']
        
        local formatted_value = string(`value', "%9.2f")
        
        if `sig_level' == 1 {
            local formatted_value = "`formatted_value'*"
        }
        else if `sig_level' == 2 {
            local formatted_value = "`formatted_value'**"  
        }
        else if `sig_level' == 3 {
            local formatted_value = "`formatted_value'***"
        }
        
        if `col' == 1 {
            putexcel B`excel_row' = "`formatted_value'"
        }
        else if `col' == 2 {
            putexcel C`excel_row' = "`formatted_value'"
        }
        else if `col' == 3 {
            putexcel D`excel_row' = "`formatted_value'"
        }
        else if `col' == 4 {
            putexcel E`excel_row' = "`formatted_value'"
        }
        else if `col' == 5 {
            putexcel F`excel_row' = "`formatted_value'"
        }
    }
}

/* Write sample sizes */
forvalues col = 1/5 {
    local sessions_val = sessions[1, `col']
    local subjects_val = subjects[1, `col']
    
    if `col' == 1 {
        putexcel B20 = "`sessions_val'"
        putexcel B21 = "`subjects_val'"
    }
    else if `col' == 2 {
        putexcel C20 = "`sessions_val'"
        putexcel C21 = "`subjects_val'"
    }
    else if `col' == 3 {
        putexcel D20 = "`sessions_val'"
        putexcel D21 = "`subjects_val'"
    }
    else if `col' == 4 {
        putexcel E20 = "`sessions_val'"
        putexcel E21 = "`subjects_val'"
    }
    else if `col' == 5 {
        putexcel F20 = "`sessions_val'"
        putexcel F21 = "`subjects_val'"
    }
}

/* Apply formatting */
putexcel A1:F21, border(all)
putexcel A1:F1, bold
putexcel A2:A21, bold
putexcel B1:F1, hcenter
putexcel B3:F21, hcenter

display "Table exported to $replication/tables/TableA2.xlsx"
display "Statistical tests used:"
display "- TotalInvestment (n_invest_subject): t-test"
display "- GroupInvestment (group_success1): Fisher's exact test"
display "- Female Session Share: Wilcoxon rank-sum test"
display "- Behavioral variables (altruism, num_safe, non_conformity, agreeableness): t-test"
display "- Age, Female, Year in College: t-test"
display "- Caste, Religion, Family Income: Fisher's exact test"
display "Significance levels: * p<0.10, ** p<0.05, *** p<0.01"


erase "$replication/temp2.dta"
