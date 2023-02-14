# Number of revisits grand analysis

Experiment 2




a 2 (fading) x 2 (resource distribution) x 2 (trial stage) x 14 (fruit consumed) analysis



Currently this df has multiple rows for each fruit - we want a single row for each fruit representing the count of revisits for that fruit



Collapse over trials to get means per stage - a mean for each combination of participant and condition where condition is 2 (fading) x 2 (resources) x 2 (stage) x 14 (fruit)




```r
# not run
options(contrasts=c("contr.sum","contr.poly"))
e2_nrevisits_grand_ANOVA <- 
  ezANOVA(data=e2_nrevisits_grand_PARTICIPANT_MEANS,
          dv=meanrevisits,
          wid=pid,
          within=c(resources,stage,fruit),
          between=fading,
          type=3)
```

That fails with

> Error in ezANOVA_main(data = data, dv = dv, wid = wid, within = within,  : 
  One or more cells is missing data. Try using ezDesign() to check your data.


<img src="e2_figures/e2ezDesign_bad_nrevisitsgrand_plot1-1.png" width="672" />

So every time (10 times) participant 3 saw a random trial in the late stage the first tree they looked at was a fruit, leaving them with no value for fruit of 0. This constitutes a structural missing.


```r
# There is a value for early
subset(e2_nrevisits_grand_PARTICIPANT_MEANS, subset=pid==3 & resources=="random" & fading=="no_fade" & stage=="early" & fruit==0)
#> # A tibble: 1 × 6
#> # Groups:   pid, resources, fading, stage [1]
#>   pid   resources fading  stage fruit meanrevisits
#>   <fct> <fct>     <fct>   <fct> <fct>        <dbl>
#> 1 3     random    no_fade early 0                0
# but there isn't a value for late (this is a structural missing)
subset(e2_nrevisits_grand_PARTICIPANT_MEANS, subset=pid==3 & resources=="random" & fading=="no_fade" & stage=="late" & fruit==0)
#> # A tibble: 0 × 6
#> # Groups:   pid, resources, fading, stage [0]
#> # … with 6 variables: pid <fct>, resources <fct>,
#> #   fading <fct>, stage <fct>, fruit <fct>,
#> #   meanrevisits <dbl>
```

One approach is to replace this missing value with zero.

Another approach would be to exclude that participant.

Another approach would be to exclude the first fruit from the analysis.

Our first attempt is to replace the structural missing with 0: after all, this is equivalent with saying that they didn't revisit any trees on their way to getting their first fruit, which is a true statement, even if it conceals that fact that they didn't have any _opportunities_ to revisit any trees on the way to getting their first fruit.

<img src="e2_figures/e2ezDesign_bad_nrevisitsgrand_plot2-1.png" width="672" />

Re-do the ANOVA (now without structural missing)






<img src="e2_tables/e2_nrevisits_grand_ANOVA.png" width="50%" />

<img src="e2_plots/e2_nrevisits_grand_PLOT10.png" width="100%" />

