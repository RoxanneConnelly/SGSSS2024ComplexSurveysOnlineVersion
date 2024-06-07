STOP
********************************************************************************
**
**# SGSSS SUMMER SCHOOL 2024: ANALYSING COMPLEX SAMPLES
** 	DR ROXANNE CONNELLY, UNIVERSITY OF EDINBURGH
**	Introduction to Complex Surveys using Stata
**
********************************************************************************

/* 	This file provides an introduction to the basics of analysing complex
	surveys in Stata.
	
	To find out more about a Stata command, remember you can always type 
	'help commandname' (e.g. help summarize) and Stata will display relevant 
	detailed documentation including helpful examples.					 	*/

		
	version 17
	
	
********************************************************************************
**
**#	A VERY SIMPLE EXAMPLE
**
********************************************************************************

/*	Here are some simple data from a hypothetical complex survey. 
	Let's open it and examine the variables.								*/
	
	use "https://www.stata-press.com/data/r16/stage5a", clear
	
	numlabel, add
	
	describe
	
	codebook, compact
	
* 	The primary sampling unit variable is called 'su1'

	summarize su1
	
* 	The strata variable is called 'strata'

	summarize strata
	
* 	The weight variable we will use is called 'pw'

	summarize pw
	
* 	This dataset also has a finite population correction variable called 'fpc1'	

	summarize fpc1
	
	
	
/* 	Now we declare the survey design.

	Take note of where the primary sampling unit, strata, weight and finite
	population correction variables are specified in this code.				*/
	
	svyset su1 [pweight=pw], strata(strata) fpc(fpc1)
	
	
* 	We can ask Stata to describe the survey design
	
	svydescribe
	
/* 	We can see that there are 3 strata.

	There are three units in each strata.
	
	There is an average of 1,226.6 observations per strata, with a minimum of
	1,152 observations and a maximum of 1,289 observations per strata. 		*/
	

* 	We can calculate the mean of the variable x2 using the code below.

	mean x2
	
/* 	This is the unadjusted mean, we have not yet taken into account the 
	design of the survey.		
	
	To take survey design into account you add the prefix 'svy:' to your
	command.																*/
	
	svy: mean x2

/*	The unadjusted mean is 0.24, the adjusted mean is 0.24.
	Not much difference! But look at the standard error and confidence
	intervals.
	
	The standard error is 0.005 for the unadjusted mean, and 0.02 for the
	adjusted mean.
	
	The standard error is a measure of the precision of the sample mean. The
	larger standard errors have taken into account the uncertainty associated
	with the complex sample.		
	
	At the top of the output you can see the number of strata and the number
	of PSUs. The design df (degrees of freedom) is the number of PSUs minus
	the number of strata (9 - 3 = 6).
	
	The number of observations is the n of the sample, and the population 
	size is an estimate of the population size.							
	
	
	
 	When we calculated the adjusted mean above we took into account the PSUs,
	strata, FPC and weight. 
	
	If we just wanted to weight we could add a weight to the end of our code.
																			*/
	
	mean x2 [pweight=pw]	
	
/*  You can see that the standard error of the mean that is only weighted
	is not as large as that seen when the analysis is fully adjusted.	
	
	When you use svy you are not just 'weighting', you are also taking into
	account clustering and stratification.									*/
	
	
	
	
	
/* 	Lets calculate the full adjusted mean again.

	Note: Stata will remember the survey design you have declared until you 
	declare a new design (i.e. run svyset again). So you don't need to run
	svyset before every command with the svy: prefix.						*/

	svy: mean x2
	
	
	

	
********************************************************************************
**
**#	DESCRIPTIVE STATISTICS AND BIVARIATE ANALYSIS
**
********************************************************************************

/* 	Let's look at a more realistic example.

	Now we open data based on the Second National Health and Nutrition 
	Examination Survey (NHANES II). 
	
	Take a moment to examine the variables in this data set.				*/
	
	use "https://www.stata-press.com/data/r16/nhanes2b", clear
	
	numlabel, add
	
	browse
	
	codebook, compact
	
	
	
/* 	This survey has a complex sample design.					
 	
	This data set does not have a finite population correction (fpc)
	
	Let's declare the design of this dataset specifying all the relevant
	features.																*/

	svyset psuid [pweight=finalwgt], strata(stratid)
	
	
* 	Lets examine the settings.

	svydescribe
	
* 	Take a moment to ensure you understand the information displayed.



* 	You already know how to find the mean of a variable.

	mean age

	svy: mean age 
	
	
	
	
/*  Finding an adjusted version of your result is as easy as adding the svy:
	prefix.
	
	Almost! 
	
	Not all commands work with the svy: prefix. For example try running
	the code below.															*/
	
	summarize age
	
	svy: summarize age
	
/*  Sometimes commands don't work with the svy prefix because the statistics
	cannot be estimated with complex survey data (we will look more at that
	later). 
	
	But other times it is simply because the command has not been written 
	with the capability to be run with svy.					
	
	To see a full list of commands that can be run with svy use the code 
	below. You can also view the help file of an individual command and it
	will indicate whether svy can be used, or not.							*/
	
	help svy estimation
	
	help summarize
	
	help mean

/*	Tip: search the help file for svy to see if it is included. You will notice
	the summarize help file doesn't mention svy but the mean help file does. */
	
	
	
	
	
* 	Here are some further commands with adjustments for the survey design.

	tabulate hlthstat
		
	svy: tabulate hlthstat
	
/* 	Note the output of the svy command is usually a little different.

	You can ask for further statistics to be displayed with your tabulate
	output.				
	
	Can you identify what each of these options do?							*/
	
	svy: tabulate hlthstat, cell count obs
	
	svy: tabulate hlthstat, cell count obs cellwidth(12) format(%12.2g) 
		
	
* 	The proportion command can also supply you with standard errors.

	proportion region
	
	svy: proportion region
	
/* 	How do the standard errors change between the unadjusted and adjusted
	results? Is this what you expected?										*/
	

	
	
	
	
* 	Lets look at the association between two categorical variables

	tabulate race diabetes
	
	tabulate race diabetes, row chi V
	
	svy: tabulate race diabetes
	
	svy: tabulate race diabetes, row se ci format(%7.4f)
	
	
	
/*	Comparing Means

	Here is another example of a command that doesn't work with svy.
	
	Below is the code to run a t-test.										*/
	
	ttest age, by(diabetes)
	
* 	This does not work with the svy: prefix

	svy: ttest age, by(diabetes)
	
* 	But we can find the means with adjustment for the sample design.

	svy: mean age, over(diabetes)
	
/* 	We can find the labels which Stata has assigned to this output using the 
	coeflegend option.														*/
	
	svy: mean age, over(diabetes) coeflegend
	
	
/* 	Now that we know the labels from the stored estimates we can use them
	in the test command to test whether there is a difference in these means.
																			*/
	test  _b[c.age@0bn.diabetes] = _b[c.age@1.diabetes]
	
	
	
	
/*	Spend a little time exploring additional variables with the commands you
	have been introduced to so far.
	
	Compare the adjusted and unadjusted results.
	
	How would your results differ if you failed to take into account the
	design of the survey?													*/
	

	

********************************************************************************
**
**#	LINEAR REGRESSION ANALYSIS
**
********************************************************************************	
	
/* 	Here we look at a linear regression 									*/

	
	regress weight height age ib1.sex ib3.region, allbaselevels

	svy: regress weight height age ib1.sex ib3.region, allbaselevels
	
	
	
/* 	Take a close look at the output of the unadjusted and adjusted models.

	There are some differences, in the adjusted model you have an estimate 
	of R-squared, which can be considered anologous to the adjusted R-squared.				
	
	You can see that the standard errors are larger in the models which 
	adjust for the design of the survey.	
	
	In this instance the difference between the unadjusted and adjusted models
	are probably not large enough to change our substantive conclusions. But
	this will not always be the case. Sufficiently large changes to standard 
	errors can lead to changes in p-values.
	
	You cannot assume a priori that the complex design of a sample will be
	inconsequential.														*/


	
	

/*	Here we will use the asdoc command to produce a table of linear regression
	results.

	We will be able to see the regression results side by side and this will 
	help us see the difference between the unadjusted and adjusted regression 
	coefficients and standard errors.
	
	You will need to install the asdoc command if you have not done so
	already.		
	
	
	If you are not familiar with asdoc - you will need to click on the blue
	text below the output to see the Word table. Remember to close the Word 
	file after viewing it or you will not be able to make edits.			*/
	
	ssc install asdoc, replace
																		
	asdoc regress weight height age ib1.sex ib3.region, allbaselevels ///
	title(Linear regression model of weight) dec(2) ///
	replace nest setstars(***@.001, **@.01, *@.05) ///
	cnames(Unadjusted) save(regressiontable.doc) replace
	

	asdoc svy: regress weight height age ib1.sex ib3.region, allbaselevels ///
	title(Linear regression model of weight) dec(2) ///
	nest setstars(***@.001, **@.01, *@.05) ///
	cnames(Adjusted) save(regressiontable.doc) append	
	
	
/*	For further guidance on preparing publication ready tables in Stata see
	here (https://www.ncrm.ac.uk/resources/online/all/?id=20788) and 
	here (https://osf.io/6h7gm/). 
	
	You can also consult the Stata Reporting Reference Manual
	(https://www.stata.com/manuals/rpt.pdf).								*/
	
	


	
	
	
********************************************************************************
**
**#	SUBPOPULATION ANALYSIS
**
********************************************************************************

/* 	In many analyses you may wish to focus on a sub-population, such as men
	or women, or a specific age group. A standard approach to this would be to
	use the 'if' command (e.g. tab age if (sex==1)), or to drop unwanted cases
	from the data set before carrying out your analysis.
	
	However, if we simply drop cases from the analysis (e.g. using if or drop)
	the standard errors of our estimates cannot be calculated correctly.
	
	Such approaches should therefore be avoided, and instead the 'subpop' 
	command should be used.
	
	When the subpop option is used, only the cases defined are used in the 
	calculation of the estimate but all cases are used in the calculation of
	standard errors. 
	
	
	Let's look at a different data set. The data below are based on the 
	National Maternal and Infant Health Survey (1988) has a stratified design. 
	We need to specify a weight and the stratum.							*/
	
	webuse nmihs, clear
	
	describe
	
	codebook, compact
	
	
* 	We declare the design of this data set.
	
	svyset [pw=finwgt], strata(stratan)
	
/* 	Let's look at the variables 'birthwgt' (birthweight) and 'highbp' high
	blood pressure.									     					*/
	
	describe birthwgt highbp
	
	mean birthwgt highbp
	
	svy: mean birthwgt highbp
	
/* 	We want to examine child's birthweight but only for mothers with high blood 
	pressure. We use the subpop option with the svy command.		  		*/
	
	svy, subpop(highbp): mean birthwgt
	
/* 	What would happen if we just used 'if' as we might normally do?			*/
	
	svy: mean birthwgt if highbp
	
/* 	The estimate of the mean is the same as we would expect but the standard
	errors are very different for the reason described above.	
	
	Let's look at a simple linear regression. We estimate a linear regression
	of birthweight with the explanatory variables of mother's age, mother's
	marital status and the baby's sex.
	
	We run the model only for mothers with high blood pressure.				*/
	
	svy, subpop(highbp): regress birthwgt age ib1.marital childsex, allbaselevels
	
	
/* 	What would happen if we used the if command?							*/
				
	svy: regress birthwgt age ib1.marital childsex if (highbp==1), allbaselevels
	
/* 	Again the coefficients are the same but there are differences in the 
	standard errors (albeit quite small differences in this example).		*/
	
	
	
	
	
	
	
********************************************************************************
**
**#	Some More Complex Issues
**
********************************************************************************

/* 	As you have seen above, sometimes Stata commands do not work after svy
	simply because they have not been written to accommodate complex surveys
	(and there is usually an alternative command that can be used).
	
	However, sometimes we cannot provide the exact same statistics in
	unadjusted and adjusted models because the statistics cannot be calculated
	in the same way.
	
	Here we return to the nhanes data, and look at an example using a logistic
	regression model. Note: the issues described below also apply to other models 
	in the Generalized Linear Model family (e.g. ologit, mlogit, poisson).	
	
	For revision of the interpretation of all elements of the logistic 
	regression output see here: 
	https://stats.oarc.ucla.edu/stata/output/logistic-regression-analysis/	 */
	
	use "https://www.stata-press.com/data/r16/nhanes2b", clear

	svyset psuid [pweight=finalwgt], strata(stratid)

	logit diabetes weight age ib2.sex ib2.region, allbaselevels
	
	svy: logit diabetes weight age ib2.sex ib2.region, allbaselevels

	
/* 	Look at how the unadjusted and adjusted results compare.

	The value of the log odds change and the standard errors also change, 
	the standard errors are a little larger in the adjusted analysis.
	
	What else is different between these two outputs?						*/


	

	
	


/*	Look carefully at the top portions of both outputs. You can see the 
	estimation block for the unadjusted model but this is not present in the 
	adjusted model.
	
	The log likelihood values from the estimation block in the unadjusted model 
	are used to calculate the likelihood ratio chi-square test and pseudo R 
	squared statistic, as well as several other model fit statistics.
	
	However we are unable to retrieve log likelihood values with an adjusted
	logistic regression. This is because the complexity of the survey violates
	the assumptions of maximum likelihood estimation, so an alternative
	estimation strategy (pseudo maximum likelihood is used). So the standard 
	model fit statistics cannot be estimated.
	
	Instead of the likelihood ratio chi-square test the adjusted model 
	presents an F-test at the top of the model output. This test tells us the 
	same as the log-likelihood ratio chi2 test. This test tells us whether this 
	model is better at explaining the outcome than the null model (i.e. a model 
	with no explanatory variables).
	
	In this example, F(6, 26) = 52.98, p < 0.001.
	
	If this test were not significant this would tell us that the variables
	you have selected do not do a good job at explaining your outcome variable.
	
	The adjusted model does not print a pseudo R2 value for the adjusted model,
	as this is also calculated from the loglikelihood values.

	You are also unable to calculate model fit statistics such as BIC and AIC 
	with an adjusted model as these also rely on loglikelihood values, 
	see below.																*/
	
	
	svy: logit diabetes weight age ib1.sex ib3.region, allbaselevels
	
	estat ic
	
/*	You will get an error message above as you cannot calculate AIC and BIC
	after svy.
	
	There have been some recent developments in the calculation of analogous
	model fit statistics for logistic regression models using complex survey
	designs.
	
	See: Lumley T (2017) "Pseudo-R2 statistics under complex sampling" 
	Australian and New Zealand Journal of Statistics DOI: 10.1111/anzs.12187 
	(preprint: https://arxiv.org/abs/1701.07745)	
	
	Some of these measures are implemented in R, but not currently in Stata
	but may be in the future.	
	
	The current standard practice is to calculate your model fit statistics 
	from an unadjusted model as an estimate, and present these alongside your
	adjusted model. 
	
	When you write up your analysis you would want to make clear that these 
	model fit statistics are estimated model fit statistics from the unadjusted 
	models (i.e. add a note to your table saying "McFadden's Pseudo R2, AIC 
	and BIC are estimated from unadjusted models.").						*/

	logit diabetes weight age ib1.sex ib3.region, allbaselevels
	
	estat ic


	
	
	
	
	
/* 	On a positive note, we do have all the required information to 
	straightforwardly calculate post estimation statistics such as average 
	marginal effects after svy: logit, in the exact same way we would with 
	an unadjusted model.
	
	Here we calculate average marginal effects of all the explanatory 
	variables in this model.												*/
	
	svy: logit diabetes weight age ib1.sex ib3.region, allbaselevels

	margins, dydx(*) asobserved post
	

		


********************************************************************************
**
** 	FURTHER HELP RESOURCES
**
********************************************************************************
	
* 	You can view an overview of Stata's svy prefix in the help file below	
	
	help svy
	
* 	You can view help for setting your data for svy analyses below
	
	help svyset
	
* 	View a list of estimation commands that work with the svy prefix below
	
	help svy estimation
	

********************************************************************************
* END OF FILE