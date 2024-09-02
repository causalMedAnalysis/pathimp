{smcl}
{* *! version 0.1, 1 July 2024}{...}
{cmd:help for pathimp}{right:Geoffrey T. Wodtke}
{hline}

{title:Title}

{p2colset 5 18 18 2}{...}
{p2col : {cmd:pathimp} {hline 2}} analysis of path-specific effects using pure regression imputation {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:pathimp} {depvar} {help indepvars:mvars} {ifin} [{it:{help weight:pweight}}] {cmd:,} 
dvar({varname}) d({it:real}) dstar({it:real}) yreg(string)
[cvars({varlist}) {opt nointer:action} {opt cxd} {opt cxm} 
reps({it:integer}) strata({varname}) cluster({varname}) level(cilevel) seed({it:passthru}) detail]

{phang}{opt depvar} - this specifies the outcome variable.

{phang}{opt mvars} - this specifies the mediators in causal order, beggining with the first in the hypothesized causal sequence
and ending with the last. Up to 5 causally ordered mediators are permitted.

{phang}{opt dvar(varname)} - this specifies the treatment (exposure) variable.

{phang}{opt d(real)} - this specifies the reference level of treatment.

{phang}{opt dstar(real)} - this specifies the alternative level of treatment. Together, (d - dstar) defines
the treatment contrast of interest.

{phang}{opt yreg}{cmd:(}{it:string}{cmd:)}} - this specifies the form of the models to be estimated for the outcome. 
Options are {opt regress} and {opt logit}.

{title:Options}

{phang}{opt cvars(varlist)} - this option specifies the list of baseline covariates to be included in the analysis. Categorical 
variables need to be coded as a series of dummy variables before being entered as covariates.

{phang}{opt nointer:action} - this option specifies whether treatment-mediator interactions are not to be
included in the appropriate outcome models (the default assumes interactions are present).

{phang}{opt cxd} - this option specifies that all two-way interactions between the treatment and baseline covariates are
included in the outcome models.

{phang}{opt cxm} - this option specifies that all two-way interactions between the mediators and baseline covariates are
included in the appropriate outcome models.

{phang}{opt reps(integer)} - this option specifies the number of replications for bootstrap resampling (the default is 200).

{phang}{opt strata(varname)} - this option specifies a variable that identifies resampling strata. If this option is specified, 
then bootstrap samples are taken independently within each stratum.

{phang}{opt cluster(varname)} - this option specifies a variable that identifies resampling clusters. If this option is specified,
then the sample drawn during each replication is a bootstrap sample of clusters.

{phang}{opt level(cilevel)} - this option specifies the confidence level for constructing bootstrap confidence intervals. If this 
option is omitted, then the default level of 95% is used.

{phang}{opt seed(passthru)} - this option specifies the seed for bootstrap resampling. If this option is omitted, then a random 
seed is used and the results cannot be replicated. {p_end}

{phang}{opt detail} - this option prints the fitted models for the outcome used to construct effect estimates. {p_end}

{title:Description}

{pstd}{cmd:pathimp} estimates path-specific effects using pure regression imputation. 

{pstd}With K causally ordered mediators, this approach is implemented as follows: 

{pstd}1. Fit a model for the mean of the outcome conditional on the exposure and baseline confounders

{pstd}2. Impute the conventional potential outcomes with the model from step 1 by setting dvar = dstar for all 
sample members, computing predicted values, and then computing the sample average of these predictions.
Similarly, use the same model to estimate the mean of the potential outcomes under exposure d by setting 
dvar = d for all sample members, computing predicted values, and then computing the sample average of these 
predictions.

{pstd}3. Impute the cross-world potential outcomes. For k = 1, 2, . . . ,K,

{pstd}(a) Fit a model for the mean of the outcome conditional on the exposure, baseline confounders, and
the mediators Mk={M1,...,Mk}.

{pstd}(b) With the model from step 3(a), set dvar = d for all sample members and compute a set
of predicted values.

{pstd}(c) Use the predicted values from step 3(b) to impute the mean of cross-world potential outcomes under
by fitting a model for these predictions conditional on the exposure and baseline confounders, setting 
dvar = dstar for all sample members, computing another set of predicted values, and then taking their sample 
average.

{pstd}4. Calculate estimates for the path-specific effects using the imputed outcomes from steps 2 and 3.

{pstd}If there are K causally ordered mediators, {cmd:pathimp} provides estimates for the total effect and then for K+1 path-specific effects:
the direct effect of the exposure on the outcome that does not operate through any of the mediators, and then a separate path-specific effect 
operating through each of the K mediators, net of the mediators that precede it in causal order. If only a single mediator is specified, 
{cmd:pathimp} reverts to estimates of conventional natural direct and indirect effects through a univariate mediator. {p_end}

{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use nlsy79.dta} {p_end}

{pstd} percentile bootstrap CIs with default settings and K=2 causally ordered mediators: {p_end}
 
{phang2}{cmd:. pathimp std_cesd_age40 ever_unemp_age3539 log_faminc_adj_age3539, dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) yreg(regress) reps(1000)} {p_end}

{pstd} percentile bootstrap CIs with default settings and K=3 causally ordered mediators: {p_end}
 
{phang2}{cmd:. pathimp std_cesd_age40 cesd_1992 ever_unemp_age3539 log_faminc_adj_age3539, dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) yreg(regress) reps(1000)} {p_end}

{pstd} percentile bootstrap CIs with default settings, K=2 causally ordered mediators, and all two-way interactions: {p_end}
 
{phang2}{cmd:. pathimp std_cesd_age40 ever_unemp_age3539 log_faminc_adj_age3539, dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) yreg(regress) cxd cxm reps(1000)} {p_end}

{pstd} percentile bootstrap CIs with default settings, K=2 causally ordered mediators, and no interactions, printing models: {p_end}
 
{phang2}{cmd:. pathimp std_cesd_age40 ever_unemp_age3539 log_faminc_adj_age3539, dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) yreg(regress) nointer reps(1000) detail} {p_end}

{title:Saved results}

{pstd}{cmd:pathimp} saves the following results in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}matrix containing the total and path-specific effect estimates{p_end}


{title:Author}

{pstd}Geoffrey T. Wodtke {break}
Department of Sociology{break}
University of Chicago{p_end}

{phang}Email: wodtke@uchicago.edu


{title:References}

{pstd}Wodtke, GT and X Zhou. Causal Mediation Analysis. In preparation. {p_end}

{title:Also see}

{psee}
Help: {manhelp regress R}, {manhelp logit R}, {manhelp bootstrap R}
{p_end}
