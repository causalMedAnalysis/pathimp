# pathimp: Analysis of Path-Specific Effects Using Pure Regression Imputation

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
- `reps(integer)`: Number of bootstrap replications, default is 200.
- `strata(varname)`: Variable that identifies resampling strata.
- `cluster(varname)`: Variable that identifies resampling clusters.
- `level(cilevel)`: Confidence level for constructing bootstrap confidence intervals, default is 95%.
- `seed(passthru)`: Seed for bootstrap resampling.
- `detail`: Prints the fitted models for the outcome.

## Description

`pathimp` estimates path-specific effects using pure regression imputation, addressing the explanatory role of multiple, causally ordered mediators.

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

## Examples

```stata
// Load data
use nlsy79.dta

// Default settings with two causally ordered mediators
pathimp std_cesd_age40, dvar(att22) mvars(ever_unemp_age3539 log_faminc_adj_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) yreg(regress) reps(1000)

// Include all two-way interactions
pathimp std_cesd_age40, dvar(att22) mvars(ever_unemp_age3539 log_faminc_adj_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) yreg(regress) cxd cxm reps(1000)

// No interactions, printing models
pathimp std_cesd_age40, dvar(att22) mvars(ever_unemp_age3539 log_faminc_adj_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) yreg(regress) nointer reps(1000) detail
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
