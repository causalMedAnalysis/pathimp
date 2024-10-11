# pathimp: A Stata Module for Analysis of Path-Specific Effects Using Pure Regression Imputation

`pathimp` is a Stata module designed to analyze path-specific effects using pure regression imputation.

## Syntax

```stata
pathimp depvar mvars, dvar(varname) d(real) dstar(real) yreg(string) [options]
```

### Required Arguments

- `depvar`: Specifies the outcome variable.
- `mvars`: Specifies the mediators in causal order, up to 5 causally ordered mediators permitted.
- `dvar(varname)`: Specifies the treatment (exposure) variable.
- `d(real)`: Reference level of treatment.
- `dstar(real)`: Alternative level of treatment, defining the treatment contrast.
- `yreg(string)`: Specifies the form of the regression model for the outcome. Options include `regress` and `logit`.

### Options

- `cvars(varlist)`: Baseline covariates to be included in the analysis.
- `nointer`: Excludes treatment-mediator interactions in the outcome model.
- `cxd`: Includes all two-way interactions between the treatment and baseline covariates.
- `cxm`: Includes all two-way interactions between the mediators and baseline covariates.
- `detail`: Prints the fitted models for the outcome.
- `bootstrap_options`: All `bootstrap` options are available.

## Description

`pathimp` estimates path-specific effects using pure regression imputation, and it computes inferential statistics using the nonparametric bootstrap. 

With `K` causally ordered mediators, the implementation proceeds as follows:

1. **Fit a Baseline Model:**
   - Fit a model for the mean of the outcome conditional on the exposure and baseline confounders.

2. **Impute Conventional Potential Outcomes:**
   - Set `dvar = dstar` for all sample members.
   - Compute predicted values using the model from Step 1.
   - Compute the sample average of these predictions.
   - Similarly, estimate the mean of the potential outcomes under exposure `d` by setting `dvar = d` for all sample members, then compute predicted values and their sample average.

3. **Impute Cross-World Potential Outcomes:**
   - For each mediator `k = 1, 2, ..., K`:
     - **(a)** Fit a model for the mean of the outcome conditional on the exposure, baseline confounders, and the mediators `Mk = {M1, ..., Mk}`.
     - **(b)** With the model from Step 3(a), set `dvar = d` for all sample members and compute a set of predicted values.
     - **(c)** Use the predicted values from Step 3(b) to impute the mean of cross-world potential outcomes under the condition set by `dvar = dstar` for all sample members, then compute another set of predicted values and take their sample average.

4. **Calculate Path-Specific Effects:**
   - Use the imputed outcomes from Steps 2 and 3 to calculate estimates for the path-specific effects.

`pathimp` provides estimates for the total effect and K+1 path-specific effects:
- The direct effect of the exposure on the outcome that does not operate through any of the mediators.
- Separate path-specific effects operating through each of the `K` mediators, net of the mediators that precede them in causal order.

If only a single mediator is specified, `pathimp` reverts to estimates of conventional natural direct and indirect effects through a univariate mediator.


`pathimp` allows sampling weights via the `pweights` option, but it does not internally rescale them for use with the bootstrap. If using weights from a complex sample design that require rescaling to produce valid boostrap estimates, the user must be sure to appropriately specify the `strata`, `cluster`, and `size` options from the `bootstrap` command so that Nc-1 clusters are sampled within from each stratum, where Nc denotes the number of clusters per stratum. Failure to properly adjust the bootstrap sampling to account for a complex sample design that requires weighting could lead to invalid inferential statistics.

## Examples

```stata
// Load data
use nlsy79.dta

// Default settings with two causally ordered mediators
pathimp std_cesd_age40, dvar(att22) mvars(ever_unemp_age3539 log_faminc_adj_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) yreg(regress) 

// Include all two-way interactions
pathimp std_cesd_age40, dvar(att22) mvars(ever_unemp_age3539 log_faminc_adj_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) yreg(regress) cxd cxm 

// No interactions, 1000 bootstrap replications, printing detailed output
pathimp std_cesd_age40, dvar(att22) mvars(ever_unemp_age3539 log_faminc_adj_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) yreg(regress) nointer detail reps(1000) 
```

## Saved Results

`pathimp` saves the following results in `e()`:

- **Matrices**:
  - `e(b)`: Matrix containing the total and path-specific effect estimates.

## Author

Geoffrey T. Wodtke  
Department of Sociology  
University of Chicago

Email: [wodtke@uchicago.edu](mailto:wodtke@uchicago.edu)

## References

- Wodtke GT, Zhou X. Causal Mediation Analysis. In preparation.

## Also See

- [regress R](#)
- [logit R](#)
- [bootstrap R](#)
