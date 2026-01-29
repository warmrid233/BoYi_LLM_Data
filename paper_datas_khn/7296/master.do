/**********************************************************************************************
File:        master.do
Authors:     Priyoma Mustafi and Ritwik Banerjee
Paper:       Using social recognition to address the gender difference in volunteering 
             for low-promotability tasks
Last edit:   5/29/2025

Description: runs all separate dofiles
***********************************************************************************************/

*-------------------------*
* Directory Configuration *
*-------------------------*

clear all
set more off
capture log close 

global replication "."

cd "$replication"

*------------------------------------------------------------------------------*

** cleaning 

do "$replication/do/cleaning"

** create small dta files for generating figs on python

do "$replication/do/create_figdata"

** summary stat and hypothesis test tables

do "$replication/do/analysis_sumstat"

** main regression tables 

do "$replication/do/analysis_main"

** appendix regression tables

do "$replication/do/analysis_appendix"

clear all
