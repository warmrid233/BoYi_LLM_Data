This zip-file contains data and analysis code for the experiment. 


Contents: 

	readme.txt: This file.

	analysis.do: Analysis code, producing all tables and graphs.

	data/mmex_situations.dta: Data file, Stata v11, with descriptive labels.

	data/mmex_situations.csv: Data file, same as above but as plain .csv text file. 
		Variable names are given in first line.

	experiment_code/*: Directory tree that contains all the Python/Django code 
		needed to run the experiment. There is a readme.txt at the root of this directory
		tree.

Variables in data with coding:

	pid: noninformative participant id

	kull: Year of study (1-5). Exact question: "Hvilket kull går du på?"

	sex: Sex. Exact question: "Er du mann eller kvinne?"
		coded:
		1: male
		2: female

	age: In years (18-34). Exact question: "Hvor gammel er du?"

	charity: Categorical variable for last years's contribution to charitable causes.
		Exact question: "Hvor mye har du i løpet av det siste året gitt til veldedige formål?"
		coded: 
			0: nothing
			1: below 500 NOK
			2: 500-1500 NOK
			3: 1500-5000 NOK
			4: Above 5000 NOK

	election: Vote in previous election. 6 participants chose not not to answer, 
	so 194 observations. Exact question: "Hvilket parti stemte du på ved forrige valg?"
		coded:
			1: SV
			2: Ap
			3: Sp
			4: V
			5: Krf
			6: H
			7: Frp
			9: Other party

	treatment: String identifier for treatment (explained in paper). 
		coded: 
			T1: Recipient is a non-working student, information is complete.
			T1*: Recipient is a non-working student, no information.
			T2: Recipient is a working student, information is complete.
			T2*: Recipient is a working student, no information.
			T3: Recipient is microcredit client, information is complete.
			T3*: Recipient is microcredit client, no information.

	decision: String identifiying choice made about information.
		coded:
			ENTRY: Elect to have information sent (in treatments T1*, T2*, T3*).
			EXIT: Elect to not have information sent (in treatments T1, T2, T3).
			NO: Made no choice to the information that would be sent.

	given1: Amount given in dictator game with default information. In NOK (0-200). 

	given2: If decision was ENTRY or EXIT, revised amount in dictator game. 
		In NOK (0-200). 88 observations.

	given_hypo: If decision was made to not change information sent (NO), response
		about hypothetical decision if they had (counterfactually) changed the 
		information. In NOK (0-200). 112 observations.



