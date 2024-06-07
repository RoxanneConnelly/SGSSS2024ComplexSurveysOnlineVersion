STOP
********************************************************************************
**
**# SGSSS SUMMER SCHOOL 2024: ANALYSING COMPLEX SAMPLES
** 	DR ROXANNE CONNELLY, UNIVERSITY OF EDINBURGH
**	Extension Activities using Stata
**
********************************************************************************


/* 	This file contains some additional extension activities which demonstrate
	the issues that often arise when we are dealing with 'real' data.
	
	To find out more about a Stata command, remember you can always type 
	'help commandname' (e.g. help summarize) and Stata will display relevant 
	detailed documentation including helpful examples.					 	*/
		
	version 17
	
	
********************************************************************************
**
** 	DATA PATH
**
********************************************************************************	
	
/*	This file will use the following data sets which can be downloaded from
	the UK Data Service (https://ukdataservice.ac.uk/).
	
	- The British Social Attitudes Survey 2019 (SN8772)
	- Understanding Society, Wave 3, 2011-2012: Teaching Dataset (SN7549)
	- Millennium Cohort Study: Fifth Survey, 2012 (SN7464)
	- Millennium Cohort Study: Longitudinal Family File, 2001-2018 (SN8172)
	
	Below I set up a macro to the location where these data files are stored
	on my machine. This will be used throughout this .do file.
	
	When you download a data set from the UKDS it will be
	in a zipped file, you should ensure the files are extracted before
	trying to open them from Stata. 
	
	The data files (.dta) will also be stored within multiple folders, you 
	might choose to move them to a simpler location.	
	
	Note: You will have to amend this code to match the location on
	your computer. If you are not familiar with setting paths you can open 
	the data sets however you usually do.									*/	
																		
	
	global data "M:\Data\NCRM"
	
	
	

	
	
********************************************************************************
**
** 	UNDERSTANDING SOCEITY (UKHLS WAVE 3 TEACHING DATASET)
**
********************************************************************************


/*	Understanding Society is also known as the United Kingdom Household
	Longitudinal Study (UKHLS).
	
	The UKHLS has a very complex sample design with multiple different 
	elements.	
	
	You can read more about the design of the UKHLS here:
	https://tinyurl.com/18nhwo6k
	
	The UKHLS dataset is very complex. There are multiple files that 
	need to be merged together and organised to enable a particular analysis.
	We are using the teaching dataset version of the third wave of UKHLS
	data collection. This is a simplified file which will allow us to 
	focus on the complex sample elements of this data in this activity.
	
	Let's open the dataset.
	
	Note: you will need to change this code to match the location on
	your computer, see the guidance above.									*/
	
	
	use "$data\und_soc_wave_3_teaching_dataset.dta", clear
	
	numlabel, add




/* 	Here we recode missing values -9 and -1  for all the variables in the 
	dataset. This will take a moment.										*/

	mvdecode _all, mv(-9/-1)


/* 	Spend a moment examining the variables in this data set. For example 
	using the code below.													*/

	describe c_screlhappy c_locserap c_locseras c_scopngbha

	codebook c_screlhappy c_locserap c_locseras c_scopngbha, compact

	tab1 c_screlhappy c_locserap c_locseras c_scopngbha


*  The PSU variable in the dataset is called 'psu'.

	summarize psu
	
* 	strata variable is called 'strata'

	summarize strata
	
	
/* 	In this data set there are three weight variables to choose from:

	c_indinub_xw - combined cross-sectional adult main interview weight
	c_ind5mus_xw - cross-sectional extra 5 minute interview person weight
	c_indscub_xw - combined cross sectional adult self-completion interview weight
	
	Guidance for how to select the correct UKHLS weight is available here:
	https://tinyurl.com/y7bqndfr
	
	See in particular:
	Table: Naming convention for Understanding Society weights w_XxxYyZz_aa
	
	From the guidance we can see that c_indinub_xw is used when you are 
	analysing:
		c_ 	- wave 3
		ind - persons 16+
		in	- interview
		ub	- GPS, EMB & BHPS (W2-W5)
		_xw	- cross sectional analysis
		
	Try and figure out when the other two weights in this dataset would 
	be used...
	
	Note that this simplified dataset does not contain all the weights 
	that are available in the full UKHLS data set (there are many more...).	*/
	
	



* 	Let's take a look at the c_indinub_xw weight variable.

	summarize c_indinub_xw
	

/* 	Note that some sample members have a weight of zero. Each Understanding 
	Society weight is set to zero for all sample units to which it does not 
	apply. Thus, specifying the use of the correct weight in analysis will 
	automatically result in the analysis being restricted to the appropriate 
	sample.																	*/
	
	

* 	Lets take a look at take home pay

	mean c_paynl

/* 	mean = £1891.48 (SE = 33.77)

	Here we have assumed that the data come from a simple random sample.
	
	But we know that this is not the case.								

	To correctly adjust for the complex design of the survey we need to 
	declare the survey design.												*/
	

	svyset psu [pweight = c_indinub_xw], strata(strata) singleunit(scaled)
	

/*	Here we have told Stata what PSU the sample members are in, what strata 
	they are in, and what weight we want to use.

	There is also an additional element added. The singleunit(scaled) option
	relates to a specific problem that can occur with 'real' complex survey
	data. Where there is a stratum in the data set with a single PSU, Stata 
	is unable to calculate the standard errors of an analysis.
	
	This is because there is insufficient information to compute an 
	estimate of that stratum's variance. Therefore, it is not possible to
	calculate the variance of estimated parameters (i.e. standard errors).
	
	In the UKHLS two Northern Ireland subsamples are simple
	random samples. Therefore these Strata will have a single PSU.
	
	To solve this problem we use the 'singleunit(scaled)' option when we 
	svyset the data. By specifying this Stata uses the average of the 
	variances from Strata with multiple sampling units for each stratum 
	with a singleton PSU.
	
	There are other options that can be used instead of the 'scaled' option,
	inclusing 'missing', 'certainty' and 'centered'. You can read further 
	details	of these in the help file.	
	
	Let's describe the design of the sample.								*/
	
	svydescribe
	
* 	You will see some stratum have 1 PSU, Stata highlights this with a *
																		
																		
/*	We now re-estimate the mean pay whilst taking into account all of the 
	features of the complex sample design.									*/

	svy: mean c_paynl


/* 	mean = £1887.25 (SE = 44.59)

	There is a change in the value of the mean and there are larger 
	standard errors associated with the adjusted estimate.					*/
	

	
	
	
/*	Try calculating the mean age of the sample (c_dvage), find the 
	unadjusted and adjusted age.											*/
	
	
	
	
	

/* 	Just to demonstrate if we had not included the singleunit option, Stata 
	would not be able to calculate the standard errors. 					*/

	svyset psu [pweight = c_indinub_xw], strata(strata)
	
	svy: mean c_paynl



	
	
/* 	Let's declare the design again with the singleunit included.			*/

	svyset psu [pweight = c_indinub_xw], strata(strata) singleunit(scaled)
	
	


/*  I discussed in the talk that some of the statistics and tests you are used 
	to using are innappropriate with complex samples data.
	
	This is partly because, with survey data, assumptions that cases are 
	independent of each other are violated. 
	
	In other cases, it may be because Stata hasn't figured out
	how to adapt the test or procedure to svyset data (or that it 
	simply hasn't been done).												*/
	
	

/* 	Lets run a linear regression model with the outcome as the pay variable
	we examined previously. The explanatory variables will be sex, age and
	education.																*/
	
	summarize c_paynl
	
	tabulate sex
	
	summarize c_dvage

	tabulate hiqual_dv
	mvdecode hiqual_dv, mv(-10)
	tabulate hiqual_dv
	
	
*	We run the unadjusted model
	
	regress c_paynl ib1.sex c_dvage ib1.hiqual_dv, allbaselevels
	

	
/* 	We run the adjusted model with a restricted set of variables and save 
	the estimates															*/

	svy: regress c_paynl ib1.sex, allbaselevels
	
	estimates store model1
	
/* 	We build on the model by adding the 'age' and 'education' variables, and
	save the estimates. 													*/ 	
	
	svy: regress c_paynl ib1.sex c_dvage ib1.hiqual_dv, allbaselevels
	
	estimates store model2	
	
*	Now we might want to run an incremetal F test to compare the nested models.
	
	ssc install ftest, replace
	
	ftest model1 model2

	
	
/*	This does not work with svy data!

	But there are often alternative commands in Stata and in this case there
	is a command that does work with svy that will allow you to undertake
	Wald tests for incremental models - nestreg.							*/
	
	xi: nestreg: svy: regress c_paynl (i.sex) (c_dvage i.hiqual_dv)
	
	
	
/*	There are also numerous linear regression post-estimation diagnostic
	commands that do not currently work with svy							*/
	
	svy: regress c_paynl ib1.sex c_dvage ib1.hiqual_dv, allbaselevels

	dfbeta
	
	estat hetttest
	
	esttat imtest
	
	estat rvfplot
	
	estat lvr2plot
	
/*  For these diagnostic tests you may wish to test the model diagnostics
	with these commands without using svy, before using svy with your 
	final model.															*/

	
	
	
	

/*	When analysing categorical outcome variables (e.g. logit, mlogit and
	ologit) with data with complex sample designs, maximum likelihood and 
	all the statistics based on maximum likelihood (e.g. BIC, AIC) are 
	inappropriate. 
	
	With complex survey data the maximum likelihood assumptions are violated.
	When you have clustering, the observations are no longer independent;
	thus the maximum likelihood estimates are not true log-likelihoods for
	the sample.						

	As a result you can't get several several statistics that you are 
	used to (e.g. LR Chi2 Test, BIC, AIC).		
	
	This is a case of the statistics being innappropriate due to the complex
	survey design, and not a case of commands just not being written to take
	svy into account.

		
	Here we prepare a variable as the outcome in a logit model.	Whether the
	respondent has a permanent job, or not.									*/
		
	tabulate c_jbterm1	
	capture drop perm
	generate perm = 1 if (c_jbterm1==1)
	replace perm = 0 if (c_jbterm1==2)
	label define permlab 1 "Permanent" 0 "Not Permanent"
	label values perm permlab
	label variable perm "Has Permanent Job"
	tabulate perm
	tabulate perm c_jbterm1
	
	
*	Let's run the model without svy
	
	logit perm ib1.sex c_dvage ib1.hiqual_dv, allbaselevels
	
	
	
* 	Now we run the model with svy
		
	svy: logit perm ib1.sex c_dvage ib1.hiqual_dv, allbaselevels


/* 	The main difference you might note is that there is no iteration
	block for the svy model and there is no log likelihood provided.

	In the output for svy:logit you get F Statistic instead of a LR Chi2
	in the top right hand side of the output.		
	
	You also get t statistics in the svy:logit model and z statistics in
	the logit model without svy.
	
	But these can all be interpreted in a similar manner.					*/


	
	
	
/* 	The UKHLS has amazing support materials. Guidance on analysing 
	Understanding Society is available here:
	https://tinyurl.com/1r01qbaf											*/			
	
	
	
	
	
	
	
	

	
********************************************************************************
**
** BRITISH SOCIAL ATTITUDES SURVEY 2019
**
********************************************************************************

/* 	The British Social Attitudes (BSA) survey series began in 1983. The series
	is designed to produce annual measures of attitudinal movements. The BSA 
	has been conducted every year since 1983, except in 1988 and 1992 when 
	core funding was devoted to the British Election Study (BES).
	
	Many 'real' complex social science datasets have complex file structures
	(i.e. multiple files) but the BSA is relatively simple as there is only
	one data file.
	
	Open the British Social Attitudes Survey 2019 (SN8772). 	

	Note: you will need to change this code to match the location on
	your computer, see the guidance above.									*/

	use "$data\bsa19_for_ukda.dta", clear
	

	
	
/* 	The British Social Attitudes Survey has a complex sample design. 

	You can read full details of the sample design here:
	https://tinyurl.com/uy46wmjm
	
	Section 4: The Sample (pages 7-8)
	
	The intended population of the British Social Attitudes survey is 
	described below.
	
	"Adults (18 and over) living in private households in Great Britain 
	(excluding the 'crofting counties' north of the Caledonian Canal)."
	
	
	
	
	The user guide contains a detailed account of how the survey weights 
	are calculated which might be of value for those interested in creating
	weights.
	
	Section 6: Weighting the data (pages 1-15)
	
	The data includes a variable that indicates the primary sampling unit 
	(spoint), the strata (StratID) and a weight (WtFactor).
	
	The weight 'WtFactor' weights for selection into the sample and for
	non-response (see page 11 of the User Guide).							*/
	
	summ spoint
	
	summ StratID
	
	summ WtFactor
	
	
/*	We can see the weight ranges from 0.29 to 4.44 

	This is an inverse probability weight. Individuals with a weight value
	greater than 1 will be 'weighted up' or count more in any analyses.
	Individuals with a weight below one will be 'weighed down' or count less
	in any analyses.
	
	Below we declare the design of the survey including the information
	that relates to the PSU, Strata and the weight.						*/
	
	svyset spoint [pweight=WtFactor], strata(StratID)
	
	
*	We examine the design of the survey

	svydescribe
	
	
	
	
	
/*	We are going to look at a series of variables from the survey.
	
	First let's examine these without adjusting for the design of the
	survey and code missing values where appropriate.		
	
	Note: an annoying thing about the British Social Attitudes Survey is that
	they mix upper and lower case letters in the variable names. Stata
	is case sensitive, so you will need to make sure you use capitals where
	required.																*/

	numlabel, add

* 	Respondent's age
	
	tabulate RageE
	mvdecode RageE, mv(98 99)
	tabulate RageE, missing
	
	summ RageE
	
* 	Respondent's sex
	
	tabulate RSex
	tabulate RSex, missing
	
* 	Respondent's marital status

	tabulate Married 
	mvdecode Married, mv(9)
	tabulate Married, missing
	
* 	Whether respondent reads a morning newspaper at least 3 days a week	
	
	tabulate Readpap
	tabulate Readpap, mi
	

/* 	The Readpap variable is coded 1 (yes) and 2 (no). It is best practice to 
	code binary variables as 1 and 0, with the affirmative response
	(i.e. yes) coded as 1.													*/

	capture drop mornpaper
	generate mornpaper = .
	replace mornpaper = 1 if (Readpap==1)
	replace mornpaper = 0 if (Readpap==2)
	label variable mornpaper "Reads morning paper at least 3 days a week"
	label define yesno 1 "Yes" 0 "No", replace
	label values mornpaper yesno
	numlabel yesno, add
	tabulate mornpaper
	tabulate mornpaper Readpap
	
	
*	Now we examine unadjusted and adjusted descriptives for these variables.

* 	Respondent's age
	
	mean RageE 
	svy: mean RageE

*	Respondent's sex

	tabulate RSex
	svy: tabulate RSex, count obs col
	
* 	Respondent's marital status
	
	tabulate Married 
	svy: tabulate Married, count obs col
	
* 	Whether respondent reads a morning newspaper at least 3 days a week	
	
	tabulate mornpaper
	svy: tabulate mornpaper, count obs col
	
	
	
	
	
/*	Let's examine the missing data in all the variables we will analyse in 
	our analysis.
	
	If you do not have the commands -mdesc- and -mvpatterns- installed you
	will need to do this.
	
	To install mvpatterns use findit, and then click on dm91, 
	then click install. 													*/
	
	ssc install mdesc, replace
	
	findit mvpatterns
	
	
	mdesc mornpaper RageE RSex Married

	mvpatterns mornpaper RageE RSex Married
	
	
	
	
	
/* 	Let's run a logistic regression of newpaper readership with age, sex
	and marital status as explanatory variables.							*/
	
	logit mornpaper RageE ib1.RSex ib1.Married, allbaselevels
	
	svy: logit mornpaper RageE ib1.RSex ib1.Married, allbaselevels
	

	
/* 	Lets look at the adjusted and unadjusted model next to each other.

	We use the 'estimates store' command to store the results under a 
	specified name. In this case we call the results m1 and m2 but we could
	call them anything.														*/
	
	
	logit mornpaper RageE ib1.RSex ib1.Married
	
	estimates store m1
	
	svy: logit mornpaper RageE ib1.RSex ib1.Married, allbaselevels
	
	estimates store m2
	
	
	
	
/*	We use the 'esttab' command to print the two models next to each other.

	The esttab command is part of the estout package. You will need to install 
	this package first.														*/
	
	ssc install estout, replace
	
	
	
/* 	We type the esttab command followed by the names of the models we wish to
	show. In this case we called the models m1 and m2 above.	
	
	We add the 'se' option so that standard errors are shown.				 */
	
	esttab m1 m2, se


/* 	Looking at the two models next to each other, you will see that there 
	are differences in the coefficients. 
	
	The standard errors are also a little wider in the adjusted model. This is 
	what we would generally expect after making these adjustments but this 
	cannot be assumed a priori.
	
	You can see that you would make some incorrect inferences if you
	did not adjust this analysis.
	
	There is no significant association observed for the gender variable
	in the adjusted analysis but there is in the unadjusted analysis.
	
	There is not a significant association for the 'never married' group
	in the unadjusted model, but there is in the adjusted model.			*/
	
	
	
	



/* 	Let's look at the variable 'peoptrst'. The British Social Attitudes Survey
	has many elements, this question was asked in the self completion
	element of the survey, rather than the face to face interview element. 
	
	The British Social Attitudes Survey has multiple versions containing
	different sets of questions, and not every respondent answers all of the
	questions. This question was only asked to those who completed version B or
	C of the survey.
	
	Reading the documentation of the data you are analysing will help you
	understand these important details in the data design.
	
	Below we examine this variable.											*/
	
	tabulate peoptrst

	
/* 	We recode this variable to create a binary variable of whether the 
	respondent says that people can generally be trusted (1) or not (0).
	
	We code category 8 (can't choose) as 0 for this simple example, but 
	different decisions could be justified.									*/
	
	capture drop trust
	generate trust = .
	replace trust = 1 if (peoptrst==1)|(peoptrst==2)
	replace trust = 0 if (peoptrst>=3)&(peoptrst<=8)
	label variable trust "Generally, people can be trusted"
	label values trust yesno
	numlabel yesno, add
	tabulate trust
	tabulate trust peoptrst
	
	
	
	
/* 	Here we run a logistic regression model with trust as the outcome variable.

	We run the unadjusted and adjusted models.								*/
	
	
	logit trust RageE ib1.RSex ib1.Married, allbaselevels

	svy: logit trust RageE ib1.RSex ib1.Married, allbaselevels
	
	
		
/*	When we adjust for the complex sample design, Stata is not able to 
	estimate standard errors. Stata tells us that there are:
	
	"Missing standard errors because of stratum with single sampling unit."
	
	But, unlike the UKHLS, we would not expect this as there is not a single
	unit stratum in the design. Why is this happening?
	
	The answer is the problem of missing data. Let's examine the missing 
	data patterns again.													*/
	
	mdesc trust RageE RSex Married

	mvpatterns trust RageE RSex Married
	
/*	Unlike the patterns of missingness we saw previously there is much more
	missing data for the trust variable. This question was asked in the self-
	completion survey which had a higher non-response rate.
	
	In your analyses you will wish to carefully examine missing data patterns
	and consider using a principled strategy to take missing data into account.
	
	In terms of using svy we can treat this scenario by using the 
	singleunit(scaled) option when declaring the complex sample design.		*/
	
	svyset spoint [pweight=WtFactor], strata(StratID) singleunit(scaled)
	
	svy: logit trust RageE ib1.RSex ib1.Married, allbaselevels
	
	
/*	As with any analysis, carefully examining patterns in your data is a
	valuable first step when analysing complex samples data.				*/
	
	
	

	
	
********************************************************************************
**
** 	MILLENNIUM COHORT STUDY SWEEP 5
**
********************************************************************************	
	
/*	The Millennium Cohort Study (MCS) is a survey that follows babies born 
	between 2000-2002 in the UK. It has a complex sample design which 
	oversamples families from minority ethnic groups, disadvantaged areas and 
	the four territories of the UK.			
	
	You can read about the design of the MCS here:
	https://tinyurl.com/4zmt6p7n										
	
	Here we look at the 'real' MCS data files for sweep 5 (i.e. data
	collected when the cohort members are age 11). We will look at this 
	briefly to give you a feel for more complex file structures and possible
	data quirks.
	
	In the MCS datasets the survey design variables, weight variables,
	and variables that might be of substantive interest are not in the 
	same file.												
	
	Let's just take a moment to look at the file containing the weight 
	variables.																*/
	
	
	use "$data\mcs_longitudinal_family_file.dta", clear
	
	
	
/* 	There are many weights available in the MCS.
	
	Spend some time exploring the MCS weight variables.						*/
	
	summarize WEIGHT1 WEIGHT2 WEIGHTGB
	
	tab1 WEIGHT1 WEIGHT2 WEIGHTGB
	
/* 	You will notice that there are weights equal to -1. You saw a weight of
	zero in the UKHLS and this meant that the case would be dropped from
	the analysis.
	
	What would happen with a weight of -1? You would get an error message
	and your analysis would not run!
	
	Whilst the -1 values in the dataset are not labelled, they represent
	missing values. These weights of -1 represent non-productive cases.
	You should therefore change these to missing values before running 
	the analysis.															*/
	
	mvdecode WEIGHT1 WEIGHT2 WEIGHTGB, mv(-1)
	
	summarize WEIGHT1 WEIGHT2 WEIGHTGB
	
	tab1 WEIGHT1 WEIGHT2 WEIGHTGB
	
	
/*	Real data leaves banana skins like this for us if we are not careful!
	Carefully examining your variables and reading the data documentation is
	key to avoiding these types of issues.
	
	Further guidance on analysing the Millennium Cohort Study is available 
	here: https://tinyurl.com/1h143jhh										*/	
	
	
	
	

	
********************************************************************************
**
** FURTHER TOPICS AND FURTHER RESOURCES
**
********************************************************************************	

/* 	

**** FURTHER DATA ANALYSIS TECHNIQUES

	There used to be greater limitations to the number of commands that can
	include the svy prefix. But commands for most more advanced data analysis
	techniques can now incorporate survey design adjustments.
	
	These include:
	
	Multiple Imputation
	
	Multilevel Modelling
	
	Panel Data Analysis
	
	Survival Analysis
		
	Structural Equation Modelling
	
	Latent Class Analysis	
	
	The Stata help files will always indicate whether and how svy can be 
	used with a particular data analysis technique.	
	

**** FURTHER HELP RESOURCES
	
* Overview of Stata's svy prefix	
	
	help svy
	
* Help for setting your data for svy analyses
	
	help svyset
	
* List of estimation commands that work with the svy prefix
	
	help svy estimation
	
* Lists of postestimation commands that work after svy
	
	help svy postestimation
	
* Post-estimation statistics for survey data
	
	help svy_estat
	
* Help for one-way tables for complex survey data
	
	help svy: tabulate oneway
	
* Help for two-way contingency tables for complex survey data	

	help svy: tabulate twoway
	
* Help for multiple imputation using complex survey data		

	help mi_xxxset
	
*/	
	

**** ENJOY YOUR RESEARCH!!

/* 	Analysing complex surveys can get frustrating at times. The command below
	might help you.															*/

	ssc install motivate, replace

	motivate	
	

********************************************************************************
* END OF FILE