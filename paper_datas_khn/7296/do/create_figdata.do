/*************************************************************************************************
File:        create_figdata.do
Authors:     Priyoma Mustafi and Ritwik Banerjee
Paper:       Using social recognition to address the gender difference in volunteering 
             for low-promotability tasks
Last edit:   5/29/2025

Description: Take cleaned data, and creates smaller relevant data for generating figs using python
**************************************************************************************************
*/

clear all
set more off
capture log close 

use "$replication/data/master.dta" , clear

*----------------------------------------------------------------------------*

preserve 
     keep n_invest_subject period treatment phase female group_success1 decision_1 session_id case_id session_size num_fem_session group
	 drop if period == 11
     save "$replication/python/data_fig/data_python_full.dta" , replace 
restore 

preserve 
         keep n_invest_subject period treatment phase female group_success1 decision_1 session_id case_id session_size num_fem_session group
		 keep if phase == 1
	 	 drop if period == 11
     save "$replication/python/data_fig/data_python_1.dta" , replace 
restore 

preserve 
        keep n_invest_subject period treatment phase female group_success1 decision_1 session_id case_id session_size num_fem_session group
	     keep if phase == 2
	 	 drop if period == 11
     save "$replication/python/data_fig/data_python_2.dta" , replace 
restore 	 