# ******************************************************************************
# **
# **  SGSSS Summer School 2024: ANALYSING COMPLEX SAMPLES
# ** 	DR ROXANNE CONNELLY, UNIVERSITY OF EDINBURGH
# **  Introduction to Complex Surveys using R
# **
# *****************************************************************************
  
# This file provides an introduction to the basics of analysing complex
# surveys in R.

# Install the packages below (if not already installed).

  install.packages(c("tidyverse", "survey"))
  
  library(tidyverse)
  library(survey)

# These are the data files which will be used.
  
  stage5afile <- "https://raw.github.com/RoxanneConnelly/SGSSS2024ComplexSurveys/master/stage5a.csv"

  nhanes2bfile <- "https://raw.github.com/RoxanneConnelly/SGSSS2024ComplexSurveys/master/nhanes2b.csv"

  nmihsfile <- "https://raw.github.com/RoxanneConnelly/SGSSS2024ComplexSurveys/master/nmihs.csv"


# ******************************************************************************
# **
# **	A VERY SIMPLE EXAMPLE
# **
# ******************************************************************************
  
#	Here are some simple data from a hypothetical complex survey. Let's open it 
# and examine it.																
	
  stage5a <- read.csv(stage5afile)
  names(stage5a)
  summary(stage5a)
  
# The primary sampling unit variable is called 'su1'

  summary(stage5a$su1)
  sd(stage5a$su1)
  length(stage5a$su1)

# The strata variable is called 'strata'

  summary(stage5a$strata)
  sd(stage5a$strata)  
  length(stage5a$strata)
  
# The weight variable we will use is called 'pw'

	summary(stage5a$pw)
	sd(stage5a$pw)
	length(stage5a$pw) 
	
# This dataset also has a finite population correction variable called 'fpc1'	

	summary(stage5a$fpc1)
	sd(stage5a$fpc1)
	length(stage5a$fpc1) 
	
# Now we declare the survey design.

#	Take note of where the primary sampling unit, strata, weight and finite
#	population correction variables are specified in this code.		
	
	stage5a_design <- svydesign(id=~su1, weights=~pw, strata=~strata, fpc=~fpc1, nest=TRUE, data=stage5a)

# We can examine details of the design we have specified.
	
	stage5a_design
	summary(stage5a_design)
	
# We can see that there are 3 strata.
#	There are three units (PSUs) in each strata.

	
# Lets examine some variables. Here we find the mean and standard error of X2
# This is the unadjusted mean and standard error, we have not yet taken the 
# complex survey design into account.

	x2sum <- stage5a |> summarise(
	          mean = mean(x2),
	          sd = sd(x2),
	           n = n(),
	          se = sd / sqrt(n), 
	          na.rm = TRUE)
	x2sum
	

# Now we take the complex survey design into account and produce an adjusted
# mean and standard deviation of variable x2. We can do this using the svymean
# command and referring to the object we have created binding the dataset
# and the details of the survey design.
	
	svymean(~x2, stage5a_design)
	
# The unadjusted mean is 0.24, the adjusted mean is 0.24. Not much difference! 
# But look at the standard errors. The standard error is 0.00485 for the 
# unadjusted mean, and 0.0208 for the adjusted mean.
	
# The standard error is a measure of the precision of the sample mean. The
# larger standard errors have taken into account the uncertainty associated
# with the complex sample.		

# When we calculated the adjusted mean above we took into account the PSUs,
# strata, FPC and weight. 

# If we just wanted to weight we would just specify this element.
	
	stage5a_justweight <- svydesign(id=~id, weights=~pw, data=stage5a)
	stage5a_justweight
	svymean(~x2, stage5a_justweight)

# You can see that the standard errors of the mean that is only weighted
# are not as large as those seen when the analysis is fully adjusted.	When you
# adjust for the complex design of a survey you are not just 'weighting', you 
# are also taking into account other elements of the survey design (e.g.
# clustering and stratification).									
	
# Lets calculate the full adjusted mean again.
  
	svymean(~x2, stage5a_design)

# ******************************************************************************
# **
# **	DESCRIPTIVE STATISTICS AND BIVARIATE ANALYSIS
# **
# ******************************************************************************
  
# Let's look at a more realistic example.

# Now we open data based on the Second National Health and Nutrition 
# Examination Survey (NHANES II). 

# Take a moment to examine the variables in this data set.
	
	nhanes <- read.csv(nhanes2bfile)
	names(nhanes)
	summary(nhanes)
	
# This survey has a complex sample design. This data set does not have a finite 
# population correction (fpc). Let's declare the design of this dataset 
# specifying all the relevant features.																

  nhanes_design <- svydesign(id=~psuid, weights=~finalwgt, strata=~stratid, nest=TRUE, data=nhanes)

# Lets examine the settings.

  nhanes_design
  summary(nhanes_design)

# Lets find the adjusted mean of age, weight and height.
  
  svymean(~age+weight+height, nhanes_design)
  
# For all other actions you will need to identify the 'survey' version of
# the command required from the 'survey' package. The documentation of this
# package is available here: https://cran.r-project.org/web/packages/survey/survey.pdf

# Here are some further commands with adjustments for the survey design.
# We start by looking at the unadjusted proportions in the hlthstat variable.

  prop.table(table(nhanes$hlthstat))

# svytable and svytotal present the adjusted total n and adjusted n and
# standard error for each category of the hlthstat variable. We first create 
# a factor for the variable as this will help us later.
  
  hlthstat.factor <- as.factor(nhanes$hlthstat)
  svytable(~hlthstat.factor, design = nhanes_design)
  svytotal(~hlthstat.factor, nhanes_design, na.rm = TRUE)
  
# We can use svymean to present the adjusted proportion in each category of
# hlthstat.
    
  svymean(~hlthstat.factor, nhanes_design, na.rm = TRUE)
  
# Another way to retrieve the adjusted proportion is to use svytable and to
# normalize the total to 1 using Ntotal.
  
  svytable(~hlthstat.factor, design = nhanes_design, Ntotal=1)
  
# Lets look at the association between two categorical variables 
# (race and diabetes), we start with looking at an unadjusted table.
  
  table_sd <- table(nhanes$race, nhanes$diabetes) 
  table_sd
  prop.table(table_sd, margin = 1)
  
# We create factors of race and diabetes and then run an unadjusted chi-square 
# test.
  
  race.factor <- as.factor(nhanes$race)
  diabetes.factor <- as.factor(nhanes$diabetes)
  
  chisq.test(table(race.factor, diabetes.factor ))
  
# Now we look at a contingency table adjusting for the complex survey design.
  
  svytable(~race+diabetes, nhanes_design, Ntotal=1)
  (table_c2 <- svytable(~race+diabetes, nhanes_design))
  svychisq(~race+diabetes, nhanes_design)
  summary(table_c2, statistic="Chisq")

#	Without adjusting for the complex survey design, below we examine the mean 
# age for people with diabetes and those without, we then conduct a t-test and 
# see significant difference between these means.
  
  aggregate(nhanes$age, list(nhanes$diabetes), FUN=mean) 
  t.test(nhanes$age~nhanes$diabetes) 
	
# We now repeat this adjusting for the complex survey design.
  
  svyttest(age~diabetes, nhanes_design)
  
# How do the results of the bivariate tests above compare between the unadjusted
# and adjusted analyses. Do these differences make sense to you?
  
# ******************************************************************************
# **
# **	LINEAR REGRESSION ANALYSIS
# **
# *******************************************************************************
	
# Here we look at an unadjusted linear regression  of weight.
  
  regress1 <- lm(weight ~ height + age + factor(sex) + factor(region), data = nhanes)
  summary(regress1)
  summary(regress1)$coef
  summary(regress1)$r.squared
  
# We estimate a linear regression model adjusting for the complex survey design.
  
  regress1_adj <- svyglm(weight ~ height + age + factor(sex) + factor(region),
                      family=gaussian(), design=nhanes_design)

  summary(regress1_adj)
  summary(regress1_adj)$coef
   
# Take a close look at the output of the unadjusted and adjusted models.
# You should expect to see larger standard errors in the adjusted model.
# In this instance the differences between the models are small and are 
# unlikely to lead to major differences in substantive conclusions but you
# cannot assume a priori that the complex design of a sample will be
# inconsequential.	
  
# The adjusted R Squared value for the unadjusted model was 0.25, but if we
# try to retrieve this for the adjusted model you will see the value is 'NULL'.
  
  summary(regress1)$r.squared
  summary(regress1_adj)$r.squared  
  
# You cannot retrieve the R Squared value in the same way when adjusting for the 
# complex survey design but we can calculate an analogous R Squared statistic
# from the residual variance and total variance of the model.

  total_var <-svyvar(~weight, nhanes_design)
  resid_var <- summary(regress1_adj)$dispersion
  rsq <- 1-resid_var/total_var
  rsq
	
# ******************************************************************************
# **
# **	SUBPOPULATION ANALYSIS
# **
# ******************************************************************************

# In many analyses you may wish to focus on a sub-population, such as men
# or women, or a specific age group. A standard approach to this would be to
# subset the dataset to filter out those you do not wish to include in 
# the analysis. 
	
# However, if we simply drop cases from the analysis the standard errors of our 
# estimates cannot be calculated correctly. The information about the sample
# design found in the excluded cases is needed to correctly estimate the 
# standard errors.
  
# Instead of subsetting the data, you should use the subset function to 
# subset the specification of the complex survey design. This will ensure
# the information from excluded cases is still used in the calculation of
# standard errors.

# Let's look at a different data set. The data below are based on the 
# National Maternal and Infant Health Survey (1988) has a stratified design. 
# We need to specify a weight and the stratum.							
  
	nmihs <- read.csv(nmihsfile)

	names(nmihs)
	summary(nmihs)
	
# We declare the design of this data set.

	nmihs_design <- svydesign(id=~idnum, weights=~finwgt, strata=~stratan, nest=TRUE, data=nmihs)
	nmihs_design	
	
# Let's look at the variables 'birthwgt' (birthweight) and 'highbp' high
#	blood pressure.						
	
	svymean(~birthwgt, nmihs_design, na.rm = TRUE)
	
	svytable(~highbp, design = nmihs_design, Ntotal=1)
	
# We want to examine child's birthweight but only for mothers with high blood 
# pressure. We first subset the specification of the complex survey design.
	
	nmihs_design_high <- subset(nmihs_design, highbp == "hi BP")
	
# Then we examine mean birthweight again using the subset design.
	
	svymean(~birthwgt, nmihs_design_high, na.rm = TRUE)
	
# What would happen if we subset the data before specifying the design?	
	
	nmihs_subset <- subset(nmihs, highbp == "hi BP")
	
	nmihs_design_wrong <- svydesign(id=~idnum, weights=~finwgt, strata=~stratan, nest=TRUE, data=nmihs_subset)
	
	svymean(~birthwgt, nmihs_design_wrong, na.rm = TRUE)
	
# The estimate of the mean is the same as we would expect, but the standard
# errors are different for the reason described above.	

# Let's look at a simple linear regression. We estimate a linear regression
# of birthweight with the explanatory variables of mother's age, mother's
# marital status and the baby's sex.

# We run the model only for mothers with high blood pressure using the 
# data with the subset design.
	
	regress2_adj <- svyglm(birthwgt ~ age + marital + childsex,
	                       family=gaussian(), design=nmihs_design_high)
	
	summary(regress2_adj)
	summary(regress2_adj)$coef
	

# What would happen if subset the data without subsetting the design?						
  
	regress3_adj <- svyglm(birthwgt ~ age + marital + childsex,
	                       family=gaussian(), design=nmihs_design_wrong)
	
	summary(regress3_adj)
	summary(regress3_adj)$coef
	
# Again the coefficients are the same but there are differences in the 
# standard errors (albeit quite small differences in this example).	
  
# ******************************************************************************
# **
# **	Some More Complex Issues
# **
# ******************************************************************************
  
# When we undertake an analysis taking into account the complex sample design
# the commands we are used to do not work, and we have to use alternatives
# designed for complex surveys data (i.e. using the 'survey' package).

# However, sometimes we cannot calculate the exact same statistics in unadjusted
# and adjusted analyses because the statistics cannot be calculated in the 
# same way (i.e. due to violations in statistical assumptions due to the 
# features of the complex survey).

# Here we return to the nhanes data, and look at an example using an unadjusted
# logistic regression model. Note: the issues described in this section also 
# apply to other models in the Generalized Linear Model family).	

	logit1 <- glm(diabetes ~ weight + age + factor(sex) + factor(region),
	                      family = "binomial"(link="logit"), data = nhanes) 
	
	summary(logit1)
	summary(logit1)$coef
	
# Now we estimate the same logistic regression model adjusting for the complex
# survey design.
	
	logit1_adj <- (svyglm(diabetes ~ weight + age + factor(sex) + factor(region), 
	                      family=quasibinomial, design=nhanes_design, 
	                      na.action = na.omit))

	summary(logit1_adj)
	summary(logit1_adj)$coef
	
# Look at how the unadjusted and adjusted results compare. The value of the log 
# odds change and the standard errors also change, the standard errors are a 
# little larger in the adjusted analysis.
	
# We can calculate pseudo R squared statistics for the unadjusted model.

	psrsq(logit1, type="Nagelkerke")
	
# Until recently it was not possible to calculate pseudo R squared statistics
# for logistic regression models (and other models in the generalized linear
# model family). However there have recently been new developments to 
# produce model fit statistics with complex surveys.
	
# See: Lumley T (2017) "Pseudo-R2 statistics under complex sampling" Australian 
# and New Zealand Journal of Statistics DOI: 10.1111/anzs.12187 (preprint: 
# https://arxiv.org/abs/1701.07745)	
	
# Lumley wrote the complex surveys package in R and has implemented some new
# pseudo R2 statistics for adjusted models which are analogous to those used
# with non-adjusted models.
	
	psrsq(logit1_adj, type="Nagelkerke")	
	
# These measures are not widely used in applied work. When reporting your
# analyses you should make clear that you have used these measures developed
# by Lumley (reference above). So actually in R this is not as much of a 
# complex issue as it used to be...

# ******************************************************************************
# **
# ** 	FURTHER HELP RESOURCES
# **
# ******************************************************************************
  
# You can view the documentation for Lumley's 'survey' package at the link below,
# which will provide details (and examples) of the full range of analyses
# that can be undertaken with complex surveys data in R.
# https://cran.r-project.org/web/packages/survey/survey.pdf
	
# This online textbook from Ramzi W Nahhas provides a helpful introduction to data
# analysis in R, including a chapter on the analysis of Complex Survey Data.
# https://www.bookdown.org/rwnahhas/RMPH/about-the-author.html
	
# This resource from UCLA ATS provides an introduction to survey data analysis
# with R: https://stats.oarc.ucla.edu/r/seminars/survey-data-analysis-with-r/
	
# ******************************************************************************
# END OF FILE